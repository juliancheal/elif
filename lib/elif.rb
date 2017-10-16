#!/usr/bin/env ruby -w

# elif.rb
#
#  Created by James Edward Gray II on 2006-01-28.
#  Copyright 2006 Gray Productions. All rights reserved.

# 
# A File-like object for reading lines from a disk file in reverse order.  See 
# Elif::new and Elif#gets for details.  All other methods are just interface 
# conveniences.
# 
# Based on Perl's File::ReadBackwards module, by Uri Guttman.
# 
class Elif
  # The version of the installed library.
  VERSION = "0.1.0".freeze
  
  # The size of the reads we will use to add to the line buffer.
  MAX_READ_SIZE = 1 << 10  # 1024
  
  # Works just line File::foreach, save that the lines come in reverse order.
  def self.foreach(name, sep_string = $/)
    open(name) do |file|
      while line = file.gets(sep_string)
        yield line
      end
    end
  end
  
  # Works just line File::open.
  def self.open(*args)
    file = new(*args)
    if block_given?
      begin
        yield file
      ensure
        file.close
      end
    else
      file
    end
  end
  
  # 
  # Works just line File::readlines, save that line Array will be in 
  # reverse order.
  # 
  def self.readlines(name, sep_string = $/)
    open(name) { |file| file.readlines(sep_string) }
  end
  
  # 
  # The first half of the Elif algorithm (to read file lines in reverse order).
  # This creates a new Elif object, shifts the read pointer to the end of the
  # file, and prepares a buffer to hold read lines until they can be returned.
  # This method also sets the <tt>@read_size</tt> to the remainer of File#size
  # and +MAX_READ_SIZE+ for the first read.
  # 
  # Technically +args+ are delegated straight to File#new, but you must open the
  # File object for reading for it to work with this algorithm.
  # 
  def initialize(*args)
    # Delegate to File::new and move to the end of the file.
    @file = File.new(*args)
    @file.seek(0, IO::SEEK_END)
    
    # Record where we are.
    @current_pos = @file.pos
    
    # Get the size of the next of the first read, the dangling bit of the file.
    @read_size = @file.pos % MAX_READ_SIZE
    @read_size = MAX_READ_SIZE if @read_size.zero?
    
    # A buffer to hold lines read, but not yet returned.
    @line_buffer = Array.new
  end
  
  # 
  # The second half on the Elif algorthim (see Elif::new).  This method returns 
  # the next line of the File, working from the end to the beginning in reverse
  # line order.
  # 
  # It works by moving the file pointer backwords +MAX_READ_SIZE+ at a time, 
  # storing seen lines in <tt>@line_buffer</tt>.  Once the buffer contains at 
  # least two lines (ensuring we have seen on full line) or the file pointer 
  # reaches the head of the File, the last line from the buffer is returned.  
  # When the buffer is exhausted, this will throw +nil+ (from the empty Array).
  # 
  def gets(sep_string = $/)
    # 
    # If we have more than one line in the buffer or we have reached the
    # beginning of the file, send the last line in the buffer to the caller.  
    # (This may be +nil+, if the buffer has been exhausted.)
    # 
    return @line_buffer.pop if @line_buffer.size > 2 or @current_pos.zero?
    
    # 
    # If we made it this far, we need to read more data to try and find the 
    # beginning of a line or the beginning of the file.  Move the file pointer
    # back a step, to give us new bytes to read.
    # 
    @current_pos -= @read_size
    @file.seek(@current_pos, IO::SEEK_SET)
    
    # 
    # Read more bytes and prepend them to the first (likely partial) line in the
    # buffer.
    # 
    @line_buffer[0] = "#{@file.read(@read_size)}#{@line_buffer[0]}"
    @read_size      = MAX_READ_SIZE  # Set a size for the next read.
    
    # 
    # Divide the first line of the buffer based on +sep_string+ and #flatten!
    # those new lines into the buffer.
    # 
    @line_buffer[0] = @line_buffer[0].scan(/.*?#{Regexp.escape(sep_string)}|.+/)
    @line_buffer.flatten!
    
    # We have move data now, so try again to read a line...
    gets(sep_string)
  end
  
  # Works just line File#each, save that the lines come in reverse order.
  def each(sep_string = $/)
    while line = gets(sep_string)
      yield line
    end
  end
  alias_method :each_line, :each  # Works just like File#each_line.
  include Enumerable              # Support all the standard iterators.
  
  # Works just line File#readline, save that the lines come in reverse order.
  def readline(sep_string = $/)
    gets(sep_string) || raise(EOFError, "end of file reached")
  end
  
  # 
  # Works just line File#readlines, save that line Array will be in 
  # reverse order.
  # 
  def readlines(sep_string = $/)
    lines = Array.new
    while line = gets(sep_string)
      lines << line
    end
    lines
  end
  
  # Works just line File#close.
  def close
    @file.close
  end
end
