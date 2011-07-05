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

module FackUp
  class Image
    class File < Struct.new(:name, :io, :time, :start, :size, :uid, :gid, :mode)
      def pack
        "%s\0%s" % [name, [time.to_i, start, size, uid, gid, mode].pack(PACK_TEMPLATE)]
      end

      def content
        io.seek(start)
        io.read(size)
      end
    end

    PACK_TEMPLATE = "LLLIII"
    PACK_SIZE     = [0, 0, 0, 0, 0, 0].pack(PACK_TEMPLATE).bytesize

    def initialize (file, mode='r', force=false)
      @files = []

      ::File.open(file, 'a'){} if force

      if mode == 'r'
        raise Errno::ENOENT, "File doesn't exist" unless ::File.exists?(file)

        @fd = ::File.open(file, 'rb')

        load_file

        [:push, :<<, :save].each {|meth|
          (class << self; self; end).class_eval { undef_method(meth) }
        }
      elsif mode == 'w'
        @fd = ::File.open(file, 'wb')
        (class << self; self; end).class_eval { undef_method(:each) }
      else
        raise "Unrecognized mode"
      end

      if block_given?
        yield self
        close
      end
    end

    def push (path)
      path = ::File.realpath(path)
      io = ::File.open(path, 'rb')
      stat = io.stat

      @files << File.new(path, io, stat.mtime, 0, io.size, stat.uid, stat.gid, stat.mode)
      self
    end
    alias << push

    def each(&blk)
      @files.each(&blk)
    end

    def save
      @fd.write(header)
      @fd.write("\0")
      @files.each {|file|
        @fd.write(file.content)
      }
    end

    def close
      if self.respond_to?(:save)
        save
      end

      @fd.close
    end

    private
    def header
      last = @files.map {|x| x.name.bytesize }.inject(:+) + @files.size * (1 + PACK_SIZE) + 1
      @files.map {|file|
        file.dup.tap {|x| x.start = last }.pack.tap {
          last += file.size
        }
      }.join
    end

    def load_file
      @files = []
      loop {
        if @fd.gets("\0").size > 1
          path = $_.strip

          args = @fd.read(PACK_SIZE).unpack(PACK_TEMPLATE)
          args[0] = Time.at(args[0])

          @files << File.new(path, @fd, *args)
        else
          break
        end
      }
    end
  end
end
