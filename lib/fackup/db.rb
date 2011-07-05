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

require 'csv'

module FackUp
  module DB
    PATH = File.join(Dir.home, '.fackup_files')

    class << self
      def path= (p)
        @path = File.realpath(p)
      end

      def path
        @path ||= PATH
      end

      def all
        touch(DB.path)
        CSV.read(DB.path).map(&:first)
      end

      def each (&blk)
        all.each(&blk)
      end

      def push (path)
        path = File.realpath(path)

        return false if all.include?(path)

        CSV.open(DB.path, 'ab') {|csv|
          csv << [path]
        }
        true
      end
      alias << push

      def delete (path)
        path = File.realpath(path)

        a = all
        return false unless a.include?(path)

        CSV.open(DB.path, 'wb') {|csv|
          (a - [path]).each {|p|
            csv << [p]
          }
        }
        true
      end

      private
      def touch (file)
        File.open(file, 'a') {}
      end
    end
  end
end
