#--
# Copyleft shura. [ shura1991@gmail.com ]
#
# This file is part of fackup.
#
# fackup is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# fackup is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with fackup. If not, see <http://www.gnu.org/licenses/>.
#++

require 'thor'
require 'fackup'

module FackUp
  class CLI < Thor
    class_option :help, type: :boolean, desc: 'Show help usage'

    desc 'version', 'Show current version'
    map '-v' => :version, '--version' => :version
    def version
      puts "fackup v#{FackUp::VERSION}"
    end

    desc 'add FILE... [OPTIONS]', 'add file to backup'
      method_option :recursive, aliases: '-r', type: :boolean, default: false,
        desc: 'Add files in directories recursively'
    def add (*files)
      files.each {|file|
        if File.directory?(file)
          if options[:recursive]
            add(Dir["#{file}/*"])
          else
            say '* ', :red
            say "#{file} is a directory."
          end
        elsif File.file?(file)
          unless DB << file
            say '* ', :red
            say "Can't add #{file}, unknown error."
          end
        else
          say '* ', :red
          say "Can't add #{file}, unknown format."
        end
      }
    end

    desc 'backup [FILE]', 'backup files'
    def backup (file=File.join(Dir.home, 'fackup_backup.img'))
      FackUp.backup(file)
    end

    desc 'restore IMAGE [OPTIONS]', 'restore image file'
      method_option :force, aliases: '-f', type: :boolean, default: false,
        desc: 'Replace files without controls'
    def restore (image)
      FackUp.send((options[:force] ? :restore_f : :restore), image)
    end

    desc 'list [IMAGE]', 'list backup files, if given, list file in image files'
    def list (image=nil)
      if image and File.exists?(image)
        FackUp::Image.new(image, 'r', true) {|img|
          img.each {|file|
            puts file.name
          }
        }
      else
        DB.each {|file|
          puts file
        } if File.exists?(DB.path)
      end
    end
  end
end
