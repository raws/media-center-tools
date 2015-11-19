require 'digest/sha1'
require 'fileutils'
require 'open-uri'

class HttpClient
  def get(url)
    cached_response(url) || open(url) { |io| cache_response(url, io.read) }
  end

  private

  def cache_file_path(cache_key)
    File.join File.dirname(__FILE__), '../tmp/cache', cache_key
  end

  def cache_key(url)
    Digest::SHA1.hexdigest url
  end

  def cache_response(url, response_body)
    cache_key = cache_key(url)
    cache_file_path = cache_file_path(cache_key)

    FileUtils.mkdir_p File.dirname(cache_file_path)
    File.write cache_file_path, response_body

    response_body
  end

  def cached?(cache_key)
    File.exist? cache_file_path(cache_key)
  end

  def cached_response(url)
    cache_key = cache_key(url)

    if cached?(cache_key)
      File.read cache_file_path(cache_key)
    end
  end
end
