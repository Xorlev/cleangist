require "gisty/version"

module Gisty
  require "highline/import"

  ## CONFIG ##
  API_KEY = ""
  @api = GithubApi.new API_KEY

  def print_gist_header(gist)
    puts "#{"#"*72}"
    puts "Files: " + gist['files'].map { |k, v| k }.join(',')
    puts "Languages: " + gist['files'].map { |k, v| v['language'] }.join(',')
    puts "Visibility: " + (gist['public'] ? "public" : "secret")
    puts gist['url']

    if gist['description'].length > 0
      puts "-"*72
      puts " #{gist['description']}"
    end

    puts "-"*72
  end

  def agree( yes_or_no_question, character = nil )
    ask(yes_or_no_question, lambda { |yn| yn.downcase[0] }) do |q|
      q.responses[:not_valid]    = 'Please enter "yes", "no", or "quit".'
      q.responses[:ask_on_error] = :question
      q.character                = character

      yield q if block_given?
    end
  end

  def print_file_contents(api, gist)
    puts api.get_gist((gist['files'].first).last["raw_url"])
  end


  def check_gists()
    api.with_gists do |gist|
      print_gist_header(gist)
      print_file_contents(api, gist)

      # y, n, see file, quit
      keep = agree "Keep gist? [y]/n/q "

      case keep
        when "n"
          api.delete_gist gist['id']
          puts "Removed gist:#{gist['id']}"
        when "q"
          exit!(0)
      end
    end
  end
end
