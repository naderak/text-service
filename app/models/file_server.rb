# Class to centralise inteface with FileServer
class FileServer
  def self.render_snippet(id, opts={})
    uri = "#{Rails.application.config_for(:text_service)["snippet_server_path"]}"
    if(opts[:op] == "osd")
      uri +="#{Rails.application.config_for(:text_service)["openSeadragon_script"]}"
    else
      uri +="#{Rails.application.config_for(:text_service)["snippet_script"]}"
    end
    uri +="?path=#{id}"
    uri += "&op=#{opts[:op]}" if opts[:op].present?
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

  ## dummy toc function returns emtpy toc
  def self.toc(arg1,arg2={})
    ""
  end

  # This function is only used for sending  xml-(TEI) files directly to the user
  # TODO: do we need this!!
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
end
