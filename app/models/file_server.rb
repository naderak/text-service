# Class to centralise inteface with FileServer
class FileServer
  def self.render_snippet(id, opts={})
    uri = "#{Rails.application.config_for(:text_service)["snippet_server_url"]}?path=#{id}"
    #uri += "&id=#{opts[:xml_id]}" if opts[:xml_id].present?
    uri += "&op=#{opts[:op]}" if opts[:op].present?
    #uri += "&c=#{opts[:c]}" if opts[:c].present?
    uri += "&prefix=#{opts[:prefix]}" if opts[:prefix].present?
    uri += "&q=#{URI.escape(opts[:q])}" if opts[:q].present?
    Rails.logger.debug("snippet url #{uri}")

    uri = URI.parse(uri)
    begin
      result = Net::HTTP.start(uri.host,uri.port) { |http|
        http.read_timeout = 20
        res = http.request_get(URI(uri))
        if res.code == "200"
          result = res.body
        else
          result ="<div class='alert alert-danger'>Unable to connect to data server</div>"
        end
        result
      }
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      Rails.logger.error "Could not connect to #{uri}"
      Rails.logger.error e
      result ="<div class='alert alert-danger'>Unable to connect to data server</div>"
    end
    result.html_safe.force_encoding('UTF-8')
  end

  def self.toc(id,opts={})
    opts[:op] = 'toc'
    FileServer.render_snippet(id, opts)
  end

  def self.toc_facsimile(id,opts={})
    opts[:op] = 'toc-facsimile'
    FileServer.render_snippet(id, opts)
  end

  def self.has_text(text)
    text = ActionController::Base.helpers.strip_tags(text).delete("\n")
    # check text length excluding pb elements
    text = text.gsub(/[s|S]\. [\w\d]+/,'').delete(' ')
    text.present?
  end

  # return all image links for use in facsimile pdf view
  def self.image_links(id, opts={})
    html = FileServer.facsimile(id, opts)
    xml = Nokogiri::HTML(html)
    links = []
    xml.css('img').each do |img|
      links << img['data-src']
    end
    links
  end

  def self.facsimile(id, opts={})
    params = {op: 'facsimile', prefix: Rails.application.config_for(:text_service)["image_server_prefix"]}
    params = opts.merge(params)
    FileServer.render_snippet(id, params)
  end

  def self.get(uri)
    Rails.logger.debug "SNIPPET SERVER GET #{uri}"
    uri = URI.parse(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 10
    http.read_timeout = 600
    begin
      res = http.start { |conn| conn.request_get(URI(uri)) }
      if res.code == "200"
        result = res.body
      else
        result ="<div class='alert alert-danger'>Unable to connect to data server</div>"
      end
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      Rails.logger.error "Could not connect to #{uri}"
      Rails.logger.error e
      result ="<div class='alert alert-danger'>Unable to connect to data server</div>"
    end

    result.html_safe.force_encoding('UTF-8')
  end

  def self.snippet_server_url
    "#{Rails.application.config_for(:text_service)["temp_snippet_server_url"]}"
  end

  def self.get_openSeadragon_script
    "#{Rails.application.config_for(:text_service)["openSeadragon_script"]}"
  end

  def self.openSeadragon_snippet(opts={})
    opts[:op] = 'json'
    opts[:prefix] = Rails.application.config_for(:text_service)["image_server_prefix"]
    ################### remove the collection #########################################
    # opts[:c] = 'adl'
    base = snippet_server_url
    base += "#{opts[:project]}" if opts[:project].present?
    ################### changed the SnippetServer to SileServer #######################
    uri = FileServer.contruct_url(base, get_openSeadragon_script, opts)
    self.get(uri)
  end

  def self.get_file(path)
    uri = URI.parse("#{Rails.application.config_for(:text_service)["temp_snippet_server_url"]}#{path}")
    begin
      result = Net::HTTP.start(uri.host,uri.port) { |http|
        http.read_timeout = 20
        res = http.request_get(URI(uri))
        if res.code == "200"
          result = res.body
        else
          result ="<div class='alert alert-danger'>Unable to connect to data server</div>"
        end
        result
      }
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      Rails.logger.error "Could not connect to #{uri}"
      Rails.logger.error e
      result ="<div class='alert alert-danger'>Unable to connect to data server</div>"
    end
  end

  private

  def self.contruct_url(base, script, opts={})
    uri = base
    uri += "/"+script
    uri += "?doc=#{opts[:doc]}" if opts[:doc].present?
    uri += "&id=#{URI.escape(opts[:id])}" if opts[:id].present?
    uri += "&mode=#{URI.escape(opts[:mode])}" if opts[:mode].present?
    uri += "&op=#{URI.escape(opts[:op])}" if opts[:op].present?
    uri += "&c=#{URI.escape(opts[:c])}" if opts[:c].present?
    uri += "&prefix=#{URI.escape(opts[:prefix])}" if opts[:prefix].present?
    uri += "&work_id=#{URI.escape(opts[:work_id])}" if opts[:work_id].present?
    uri += "&status=#{URI.escape(opts[:status])}" if opts[:status].present?
    uri += "&q=#{URI.escape(opts[:q])}" if opts[:q].present?
    uri
  end

end
