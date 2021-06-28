#!/usr/bin/ruby

require 'json'
require 'socket'
require 'net/http'
require 'securerandom'

server = TCPServer.new(ENV['PORT'])


begin
    file = File.open("servers.json", "r")
    servers = JSON.parse(file.read)
    file.close
    $servers = servers["servers"]
rescue Errno::ENOENT
    abort "\e[1;31mConfig file not found\e[0m"
rescue JSON::ParserError
    abort "\e[1;31mConfig parse error\e[0m"
end


def getheader(msg, code)
    header = "HTTP/1.1 #{code}\r\n"
    header += "server: randbalance\r\n"
    header += "date: #{Time.now}\r\n"
    header += "content-type: text/html\r\n"
    header += "content-length: #{msg.length}\r\n"
    header += "\r\n"
    header += "#{msg}"
    return header
end


def sendrequest(req)
    begin
        server = $servers[rand($servers.length)]
        host = server["host"]
        w = TCPSocket.new(host, server["port"])
        w.write(req + "\n")
        res = w.recv(2000)
        w.close
    rescue => err
        log = File.open("errors.csv", "a")
        errid = SecureRandom.uuid
        log.puts("#{errid}, #{Time.now}, #{err}")
        log.close
        return false, errid
    end
    return res
end


while client = server.accept
    Thread.start do
        req = client.readpartial(3000)
        res = sendrequest(req)
        if !res[0]
            htm = File.open("error.html", "r")
            client.write(getheader(htm.read.gsub("((ERR))", "Error ID : #{res[1].to_s}"), 500))
            htm.close
            client.close
            Thread.exit
        end
        client.write(res)
        client.close
    end
end
