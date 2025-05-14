#!/usr/bin/env python3

import os
import re
import sys
import json
import random
import numpy as np
from PIL import Image
from os import path
from wordcloud import WordCloud, STOPWORDS
import openai
import matplotlib.pyplot as plt
from dotenv import load_dotenv
load_dotenv()

d = path.dirname(__file__) if "__file__" in locals() else os.getcwd()

output_dir = sys.argv[2] if len(sys.argv) > 2 else d

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

# Get special terms from config or use defaults
SPECIAL_TERMS = config.get('special_terms', ['e-', 'i-', '2-', '3-', '4-', '.com', 'tr.ee', 'ai', 'web'])
print(f"Using special terms: {SPECIAL_TERMS}")

# Get batch size from config or use default
BATCH_SIZE = int(config.get('batch_size', 500))
print(f"Using batch size: {BATCH_SIZE}")

# Function to extract words using OpenAI API
def extract_words_with_openai(domain_names, special_terms, batch_size=BATCH_SIZE):
    # Get API key from environment variable
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        raise ValueError("OpenAI API key not found. Set the OPENAI_API_KEY environment variable.")
    
    # Get model and temperature from environment variables
    model = os.environ.get("OPENAI_MODEL", "gpt-4.1-2025-04-14")
    temperature = float(os.environ.get("OPENAI_TEMPERATURE", "0.3"))
    max_tokens = int(os.environ.get("OPENAI_MAX_TOKENS", "2000"))

    # Process domains in batches
    all_words = []
    total_prompt_tokens = 0
    total_completion_tokens = 0
    total_cost = 0

    # Calculate number of batches
    num_batches = (len(domain_names) + batch_size - 1) // batch_size
    
    for i in range(0, len(domain_names), batch_size):
        batch = domain_names[i:i+batch_size]
        print(f"Processing batch {i//batch_size + 1}/{num_batches} ({len(batch)} domains)...")
        sys.stdout.flush()
        
        # Prepare the prompt with domain names and special terms
        domains_text = "\n".join(batch)
        special_terms_text = ", ".join([f"`{term}`" for term in special_terms])
        
        prompt = f"""You are a bilingual Estonian-English linguist and word segmentation expert. I will give you a list of .ee domain names.

Your task is to extract a clean list of words for word cloud generation.

Follow these rules strictly:
1. Before doing anything else, always extract and separate these predefined special terms if they appear as prefixes or parts of the domain name: {special_terms_text}. Keep symbols and numbers as they are. For example, if the domain name is `e-robot.ee`, the output should be `e- robot`. Remove extensions from the special terms.
2. If a word contains a number (e.g., `auto24`), separate the number and the word: `auto`, `24`.
3. If the domain name is a compound of 2+ Estonian or English words (e.g., `virtuaalabiline` or `doorkeeper`), intelligently split them into individual meaningful components. Prioritize Estonian words over English words.
4. Keep all resulting words in lowercase and remove the `.ee` extension from all the words
5. Try to find the most common words and phrases in the domain names.
6. Return ONLY a space-separated list of words and numberswith no explanations, no formatting, no introductions, and no additional text.

Example output format:
word1 word2 word3 word4 word5

Here are the domain names:
{domains_text}
"""

        # Make the API call
        try:
            print(f"Using model: {model} with temperature: {temperature}")
            response = openai.chat.completions.create(
                model=model,
                messages=[
                    {"role": "system", "content": "You are a helpful assistant that extracts words from domain names. You ONLY output the extracted words with no additional text."},
                    {"role": "user", "content": prompt}
                ],
                temperature=temperature,
                max_tokens=max_tokens
            )
            
            # Track token usage
            prompt_tokens = response.usage.prompt_tokens
            completion_tokens = response.usage.completion_tokens
            total_tokens = response.usage.total_tokens

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
            total_cost += batch_cost
            print(f"Estimated batch cost: ${batch_cost:.6f}")

            # Extract the words from the response
            words_text = response.choices[0].message.content.strip()
            
            # Process the response to get a clean list of words
            batch_words = []
            for line in words_text.split('\n'):
                line = line.strip()
                if line and not line.startswith('```') and not line.endswith('```'):
                    # Remove any list markers like "1. ", "- ", etc.
                    cleaned_line = re.sub(r'^[\d\-\*\•\.\s]+', '', line)
                    if cleaned_line:
                        batch_words.extend(cleaned_line.split())
            
            all_words.extend(batch_words)
            print(f"Extracted {len(batch_words)} words from this batch")
            
        except Exception as e:
            print(f"Error calling OpenAI API for batch: {e}")

    print(f"Total token usage - Prompt: {total_prompt_tokens}, Completion: {total_completion_tokens}")
    print(f"Total estimated cost: ${total_cost:.6f}")
    
    return all_words

# Process domain names using OpenAI
print("Extracting words from domain names using OpenAI...")
extracted_words = extract_words_with_openai(domain_names, SPECIAL_TERMS)
print(f"Extracted {len(extracted_words)} words")
# print("Sample of extracted words:", extracted_words)

# Join the extracted words for the word cloud
processed_text = ' '.join(extracted_words)
# print("Processed text sample:", processed_text)

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