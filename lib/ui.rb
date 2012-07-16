require './lib/brain'
require './lib/user'
include Transport

class UI
  def initialize
    length_of_users = Transport::User.find(:all).length
    puts "Welcome to Bart or Drive!\n\n"
    if length_of_users == 0
      add_user
      start(@user.first_name, @user.last_name)

      puts @origin.class
    else
      puts "Please select user (1-#{length_of_users}):\n"
      list_users
      input = gets.chomp
      if input.to_i(10).between?(1, length_of_users)
        user = Transport::User.find(:all)[input.to_i(10)-1]
        fname = user.first_name
        lname = user.last_name
        start(fname, lname)
      else
        raise "Dude...Shereef...c'mon."
      end
    end
  end

  def add_user
    puts "Please enter your first and last name."
    input = gets.chomp
    arr = input.split
    @user = Transport::User.new(:first_name => arr[0], :last_name => arr[1])
    @user.save
  end

  def list_users
    list = "\n"
    users = Transport::User.find(:all).each_with_index do |user, index|
      list << "[#{index+1}]  #{user.first_name} #{user.last_name}\n"
    end
    puts list
    puts '------------------------------------------------'
  end

  def start(fname, lname)
    @origin
    @destination
    make_a_brain(fname, lname)
    puts "\nHello #{@user.first_name}!\n\n"
    @command = ' '
    run
  end

  def make_a_brain(fname, lname)
    @user = User.find(:first, :conditions => {:first_name => fname, :last_name => lname}) ||
            User.create(:first_name => fname, :last_name => lname)
    @recents = @user.addresses.length
    @brain = Brain.new(@user)
  end

  def run
    if @origin.nil?
       puts "Select origin!"
       print_options
       @origin = select_address
       run if !@origin.nil?
     else
       puts "\nOrigin: #{@origin}"
       puts "\nNow, select destination!"
       print_options
       @destination = select_address
       if !@destination.nil? && @destination != @origin
         decision
         need_i_say_more
       elsif @destination == @origin
         puts "You're already at your destination!"
         need_i_say_more
       end
     end
  end

  def select_address
    list_addresses
    puts '------------------------------------------------'
    command = gets.chomp
    if command == 'a'
      add_new_address
    elsif command.to_i(10).between?(1, @recents)
      @brain.list_addresses[command.to_i(10)-1]
    elsif command == 'q'
      puts 'Bye!'
      nil
    else
      puts "Sorry - I don't know that command... Here are your options:"
      run
    end
  end

  def add_new_address
    puts "\nEnter the new address:"
    raw_address = gets.chomp
    if @origin.nil?
      puts "\n"
      raw_address
    else
      puts "\n"
      raw_address
    end
  end


  def need_i_say_more
    puts "Do you need more advice (yes/no)?"
    response = gets.chomp
    puts "\n"
    if response == "yes" || response == "y"
      @destination = nil
      @origin = nil
      run
    elsif response == "no" || response == "n"
      puts 'Bye!'
    else
      puts "I don't know that command... Bye!"
    end
  end

  def print_options
    if @recents > 0
      puts <<-EOF

      Here are your options:

      [1-#{@recents}] Select an address from the list below
      [a] Add a new address
      [q] Quit
      EOF
    else
      puts <<-EOF

      Here are your options:

      [a] Add a new address
      [q] Quit
      EOF
    end
  end


  def list_addresses
    list = "\n"
    @brain.list_addresses.each_with_index do |address, index|
      list << "[#{index+1}]  #{address}\n"
    end
    puts list
  end

  def decision
    decision = @brain.decision(@origin, @destination).to_s.upcase
    puts "\nLet me think about it..."
    sleep 0.5
    puts "."
    sleep 0.5
    puts ".."
    sleep 0.5
    puts "..."
    sleep 0.5
    puts "...."
    puts "#{decision} will take #{@brain.time_difference} minutes less time than #{decision == "TRANSIT" ? "NO" : "TRANSIT"}!\n\n"
    @brain.save_to_db(@user)
  end
end
