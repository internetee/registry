#!/usr/bin/env python3

import os
import re
import sys
import json
import random
import asyncio
import numpy as np
from PIL import Image
from os import path
from wordcloud import WordCloud, STOPWORDS
from openai import AsyncOpenAI
import matplotlib.pyplot as plt
# import pandas as pd
from dotenv import load_dotenv
load_dotenv()

BATCH_SIZE = int(os.environ.get("OPENAI_BATCH_SIZE", "20"))

def load_system_prompt():
    """Loads system prompt from system_prompt.md file"""
    prompt_file = path.join(path.dirname(__file__), 'system_prompt.md')
    
    if not path.exists(prompt_file):
        raise FileNotFoundError(f"System prompt not found at {prompt_file}. Please create the file.")
    
    with open(prompt_file, 'r', encoding='utf-8') as f:
        system_prompt = f.read()
    
    return system_prompt

d = path.dirname(__file__) if "__file__" in locals() else os.getcwd()

output_dir = sys.argv[2] if len(sys.argv) > 2 else d

try:
    SYSTEM_PROMPT = load_system_prompt()
    print("System prompt successfully loaded from file.")
except FileNotFoundError as e:
    print(f"Error: {e}")
    sys.exit(1)

# Load configuration if provided
config = {}
if len(sys.argv) > 3 and sys.argv[3]:
    config_file = sys.argv[3]
    if path.exists(config_file):
        with open(config_file, 'r') as f:
            config = json.load(f)
        print(f"Loaded configuration: {config}")

# Check if domains file path is provided and exists
if len(sys.argv) > 1 and sys.argv[1]:
    domains_file = sys.argv[1]
    if not path.exists(domains_file):
        print(f"Error: Provided domains file {domains_file} not found")
        sys.exit(1)
else:
    print(f"Error: Domains file not found")
    sys.exit(1)

# Read domain names from the file
with open(domains_file, 'r', encoding='utf-8') as f:
    domain_names = [line.strip().lower() for line in f if line.strip()]

if not domain_names:
    print("Error: No domain names found in the provided file")
    sys.exit(1)


# Function to extract words using OpenAI API asynchronously
async def extract_words_with_openai(domain_names, batch_size=BATCH_SIZE):
    filtered_domains = []
    
    # Filter out domains that are only numbers
    for domain in domain_names:
        domain_core = domain.lower().replace('www.', '')
        main_part = domain_core.split('.')[0]
        if not main_part.isdigit():
            filtered_domains.append(domain)
    
    
    # Get API key from environment variable
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        raise ValueError("OpenAI API key not found. Set the OPENAI_API_KEY environment variable.")
    
    # Initialize AsyncOpenAI client
    client = AsyncOpenAI(api_key=api_key)
    
    # Get model and temperature from environment variables
    model = os.environ.get("OPENAI_MODEL", "gpt-4o-2024-11-20")
    temperature = float(os.environ.get("OPENAI_TEMPERATURE", "0"))
    max_tokens = int(os.environ.get("OPENAI_MAX_TOKENS", "16000"))

    # Process domains in batches
    all_words = []
    total_prompt_tokens = 0
    total_completion_tokens = 0
    total_cost = 0

    # Calculate number of batches
    num_batches = (len(filtered_domains) + batch_size - 1) // batch_size
    
    # Create semaphore to limit concurrent requests
    semaphore = asyncio.Semaphore(10)  # Limit to 10 concurrent requests
    
    async def process_batch(batch_idx):
        async with semaphore:
            start_idx = batch_idx * batch_size
            end_idx = min(start_idx + batch_size, len(filtered_domains))
            batch = filtered_domains[start_idx:end_idx]
            
            print(f"Processing batch {batch_idx + 1}/{num_batches} ({len(batch)} domains)...")
            sys.stdout.flush()
            
            # Prepare the prompt with domain names and special terms
            domains_text = "\n".join(batch)
            prompt = f"List of domain names: {domains_text}"

            # Make the API call
            try:
                print(f"Using model: {model} with temperature: {temperature}")
                response = await client.chat.completions.create(
                    model=model,
                    messages=[
                        {"role": "system", "content": SYSTEM_PROMPT},
                        {"role": "user", "content": prompt}
                    ],
                    response_format={
                        "type": "json_schema",
                        "json_schema": {
                        "name": "domain_analysis_results",
                        "strict": True,
                        "schema": {
                            "type": "object",
                            "properties": {
                            "results": {
                                "type": "array",
                                "description": "A list of analysis results for the provided domains.",
                                "items": {
                                "type": "object",
                                "properties": {
                                    "Language": {
                                    "type": "string",
                                    "description": "The language identified in the domain name."
                                    },
                                    "is_splitted": {
                                    "type": "string",
                                    "description": "Indicates whether the domain name is split into recognizable words."
                                    },
                                    "reasoning": {
                                    "type": "string",
                                    "description": "Explanation of the reasoning behind the language and word identification."
                                    },
                                    "words": {
                                    "type": "array",
                                    "description": "The words identified in the domain name.",
                                    "items": {
                                        "type": "string"
                                    }
                                    }
                                },
                                "required": [
                                    "Language",
                                    "is_splitted",
                                    "reasoning",
                                    "words"
                                ],
                                "additionalProperties": False
                                }
                            }
                            },
                            "required": [
                            "results"
                            ],
                            "additionalProperties": False
                        }
                        }
                    },
                    temperature=temperature,
                    max_tokens=max_tokens,
                )
                
                # Track token usage
                prompt_tokens = response.usage.prompt_tokens
                completion_tokens = response.usage.completion_tokens
                total_tokens = response.usage.total_tokens

                nonlocal total_prompt_tokens, total_completion_tokens
                total_prompt_tokens += prompt_tokens
                total_completion_tokens += completion_tokens
                
                print(f"Token usage - Prompt: {prompt_tokens}, Completion: {completion_tokens}, Total: {total_tokens}")
                
                # Calculate cost (approximate, based on current pricing)
                if "gpt-4.1" in model:
                    prompt_cost = (prompt_tokens / 1000000) * 2.00  # $2.00 per 1M tokens for GPT-4.1 input
                    completion_cost = (completion_tokens / 1000000) * 8.00  # $8.00 per 1M tokens for GPT-4.1 output
                else:
                    prompt_cost = 0
                    completion_cost = 0
                    
                batch_cost = prompt_cost + completion_cost
                nonlocal total_cost
                total_cost += batch_cost
                print(f"Estimated batch cost: ${batch_cost:.6f}")

                # Extract the words from the response
                response_json = json.loads(response.choices[0].message.content)
                batch_words = []
                for result in response_json['results']:
                    if result['Language'] == 'Ignore':
                        continue
                    batch_words.extend(result['words'])
                
                print(f"Extracted {len(batch_words)} words from this batch")
                return batch_words
                
            except Exception as e:
                print(f"Error calling OpenAI API for batch: {e}")
                return []
    
    # Create tasks for each batch
    tasks = []
    for batch_idx in range(num_batches):
        tasks.append(process_batch(batch_idx))
    
    # Run all tasks concurrently and wait for results
    batch_results = await asyncio.gather(*tasks)
    
    # Combine all words from all batches
    for batch_words in batch_results:
        all_words.extend(batch_words)

    print(f"Total token usage - Prompt: {total_prompt_tokens}, Completion: {total_completion_tokens}")
    print(f"Total estimated cost: ${total_cost:.6f}")
    
    return all_words

# Replace the synchronous call with an async function
async def main():
    # Process domain names using OpenAI
    print("Extracting words from domain names using OpenAI...")
    extracted_words = await extract_words_with_openai(domain_names)
    print(f"Extracted {len(extracted_words)} words")
    
    # Join the extracted words for the word cloud
    processed_text = ' '.join(extracted_words)
    
    def custom_color_func(word, font_size, position, orientation, random_state=None,
                        **kwargs):
        return "hsl(215, 100%%, %d%%)" % random.randint(15, 80)

    mask = np.array(Image.open(path.join(d, 'mask.png')))

    # Get configuration values with defaults
    width = int(config.get('width', 800))
    height = int(config.get('height', 800))
    max_words = int(config.get('max_words', 500))
    background_color = config.get('background_color', 'white')
    min_word_length = int(config.get('min_word_length', 2))
    include_numbers = config.get('include_numbers', True)

    # Handle transparent background
    if background_color == 'transparent':
        background_color = None

    # Get additional stopwords
    additional_stopwords = config.get('additional_stopwords', [])

    stopwords = set(STOPWORDS)
    stopwords = {
        'ja', 'ning', 'et', 'kui', 'aga', 'ka', 'ei', 'see', 'on', 'ole', 
        'oma', 'seda', 'siis', 'või', 'mis', 'nii', 'veel', 'kes', 'üle', 
        'välja', 'olema', 'kus', 'nagu', 'kuid', 'selle', 'pole', 'ära', 
        'vaid', 'sest', 'juba', 'meie', 'mida', 'need', 'olid', 'minu', 
        'tema', 'pärast', 'mingi', 'palju', 'kõik', 'seal', 'olen', 'oled', 
        'oli', 'olnud', 'ongi', 'poolt', 'meil', 'teda', 'just', 'kuna', 
        'läbi', 'küll',
        'the', 'and', 'a', 'to', 'of', 'in', 'is', 'that', 'it', 'for',
        'with', 'as', 'be', 'on', 'not', 'this', 'but', 'by', 'from', 'are',
        'or', 'an', 'at', 'was', 'have', 'has', 'had', 'were', 'will', 'would',
        'should', 'can', 'could', 'may', 'might', 'must', 'do', 'does', 'did',
        'doing', 'done', 'their', 'they', 'them', 'there', 'these', 'those',
        'which', 'who', 'whom', 'whose', 'what', 'when', 'where', 'why', 'how'
    }

    stopwords.update(stopwords)
    stopwords.update(additional_stopwords)

    font_path = path.join(d, 'fonts', 'Pacifico-Regular.ttf')
    # Alternative: use a system font
    # font_path = fm.findfont(fm.FontProperties(family='Arial'))

    print("Generating word cloud...")
    wc = WordCloud(width=width, height=height, 
                mask=mask, 
                stopwords=stopwords,
                background_color=background_color, 
                max_words=max_words,
                include_numbers=include_numbers, 
                collocations=False,
                min_word_length=min_word_length, 
                regexp=r"[A-Za-zÕÄÖÜõäöü0-9][\w\-'ÕÄÖÜõäöü]*(?<!\.ee)(?<!ee)",
                font_path=font_path) 

    wc.generate(processed_text)

    # Get word frequencies from the word cloud
    word_frequencies = wc.process_text(processed_text)
    # Remove stopwords from the frequencies
    word_frequencies = {word: freq for word, freq in word_frequencies.items() 
                    if word.lower() not in stopwords}

    # Sort words by frequency (highest first)
    sorted_words = sorted(word_frequencies.items(), key=lambda x: x[1], reverse=True)

    # Get top 10 words
    top_10_words = sorted_words[:10]

    # Print top 10 words to console
    print("\nTop 10 most frequent words:")
    for word, freq in top_10_words:
        print(f"{word}: {freq}")

    # Save top 10 words to a text file
    top_words_file = path.join(output_dir, 'top_words.txt')
    with open(top_words_file, 'w', encoding='utf-8') as f:
        f.write("Top 10 most frequent words:\n")
        for i, (word, freq) in enumerate(top_10_words, 1):
            f.write(f"{i}. {word}: {freq}\n")

    print(f"\nTop words saved to {top_words_file}")

    # store default colored image
    default_colors = wc.to_array()
    # Display the word cloud
    plt.imshow(wc.recolor(color_func=custom_color_func, random_state=3),
            interpolation="bilinear")
    plt.axis('off')
    plt.show()

    # Save the word cloud to file
    wc.to_file(path.join(output_dir, 'wordcloud.png'))

# Call the async main function
if __name__ == "__main__":
    # Run the async main function
    asyncio.run(main())
