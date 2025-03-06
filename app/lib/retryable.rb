# frozen_string_literal: true

# Module for retrying operations with external APIs
module Retryable
  # Executes a code block with a specified number of retry attempts in case of specific errors
  # @param max_attempts [Integer] maximum number of attempts (defaults to 3)
  # @param retry_delay [Integer] delay between attempts in seconds (defaults to 2)
  # @param exceptions [Array<Class>] exception classes to catch (defaults to all exceptions)
  # @param logger [Object] logger object (must support info, warn, error methods)
  # @param fallback [Proc] code block executed if all attempts fail
  # @return [Object] result of the block execution or fallback
  def with_retry(
    max_attempts: 3,
    retry_delay: 2,
    exceptions: [StandardError],
    logger: Rails.logger,
    fallback: -> { [] }
  )
    attempts = 0

    retry_attempt = lambda do
      attempts += 1
      yield
    rescue *exceptions => e
      logger.warn("Attempt #{attempts}/#{max_attempts} failed with error: #{e.class} - #{e.message}")
      
      if attempts < max_attempts
        logger.info("Retrying in #{retry_delay} seconds...")
        sleep retry_delay
        retry_attempt.call
      else
        logger.error("All attempts exhausted. Last error: #{e.class} - #{e.message}")
        fallback.call
      end
    end
    
    retry_attempt.call
  end
end 