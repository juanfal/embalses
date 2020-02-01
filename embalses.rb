#!/usr/bin/env ruby -KU
# embalses.rb
# 2019-06-18
# https://gist.github.com/d159f4344fc23385a5f6b90d99603c11

require 'fileutils'
require 'nokogiri'
require 'open-uri'
require 'date'

$href= 'https://www.embalses.net/provincia-42-malaga.html';

# macosx open url in browser
if RUBY_PLATFORM["darwin"] and ARGV.length > 0 then
    if ARGV[0] == "-h"
        puts "
        Usage #{File.basename($0)} [-h|anyletter]

          with anyletter it will open #$href on browser
        "
    else
        system "open #$href"
    end
    exit 0
end

$savepath= File.join(Dir.home,'embalsado-malaga');
# Ensure save paths
Dir.mkdir($savepath) if not Dir.exists?($savepath)

def fetchembalses()
    r = {}
    url = $href
    cnt = 0
    begin
        doc = Nokogiri::HTML(open(url))

    rescue
        cnt += 1
        retry if cnt < 2
    end
    if not doc
        $stderr.puts "Not found"
        exit 1
    end
    datos = doc.css('.FilaSeccion').text
    datos =~ /Agua embalsada.*?:.*?([\d\.]+)\s*%.*?Anterior:.*?([-+\d\.]+)\s*%.*Capacidad:\s*(\d+).*?Misma Semana.*?:.*?([\.\d]+)\s*%.*?Misma Semana.*?:.*?([\.\d]+)\s*%/m
    r[:ahora] = $1.to_f
    r[:difSemana] = $2.to_f
    r[:capacidad] = $3.to_i
    r[:año] = $4.to_f
    r[:media10] = $5.to_f

    return r
end

r = fetchembalses()
now = Time.now
nowshort = now.strftime("%Y-%m-%d")
outfilelog = File.join($savepath, nowshort  + ".txt")
File.open(outfilelog, "a") do |f|
  f.write( sprintf("%s\t%g\n" % [nowshort, r[:ahora] ]) )
end
printf("%g%% (%g) [%d: %g, media: %g]\n", r[:ahora], r[:difSemana], now.year-1, r[:año], r[:media10])
