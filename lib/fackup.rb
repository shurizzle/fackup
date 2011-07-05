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

require 'fileutils'
require 'fackup/db'
require 'fackup/image'

module FackUp
  VERSION = '0.0.1'

  def self.restore (image)
    FackUp::Image.new(image, 'r', true) {|img|
      img.each {|file|
        FileUtils.mkdir_p(File.dirname(file.name))

        if File.exists?(file.name)
          stat = File.stat(file.name)

          next if file.time == stat.mtime and file.size == File.size(file.name) and
            file.uid == stat.uid and file.gid == stat.gid and file.mode == stat.mod
        end

        begin
          File.open(file.name, 'wb') {|f|
            f.write(file.content)
          }
        rescue Errno::EACCES
          next
        end

        File.chown(file.uid, file.gid, file.name)
        File.chmod(file.mode, file.name)
        File.utime(file.time, file.time, file.name)
      }
    }
  end

  def self.restore_f (image)
    FackUp::Image.new(image, 'r', true) {|img|
      img.each {|file|
        FileUtils.mkdir_p(File.dirname(file.name))

        begin
          File.open(file.name, 'wb') {|f|
            f.write(file.content)
          }
        rescue Errno::EACCES
          next
        end

        File.chown(file.uid, file.gid, file.name)
        File.chmod(file.mode, file.name)
        File.utime(file.time, file.time, file.name)
      }
    }
  end

  def self.backup (file)
    FackUp::Image.new(file, 'w', true) {|img|
      DB.each {|file|
        unless File.readable?(file)
          next
        end

        img << file
      }
    }
  end
end
