class RexTimeoutError < StandardError
end

class SuperAwesomeRexTimeoutError < RexTimeoutError
end
require 'pry-byebug'


class Session
    # 1)
    attr_accessor :on_error_proc

    # 2)
    # attr_accessor :error_handler

    def run_powershell
        if rand > 0.5
            raise RexTimeoutError, 'oh timeout'
        else
            raise 'oh no mystery exception '
        end
    rescue => e
        # 1) Either use procs:
        on_error_proc.call(e) if on_error_proc

        # 2) Or subjects, we expect the error handler to be an object that has a handle_error method
        # error_handler.handle_error(e) if error_handler

        raise e
    end
end

###############################
# First example with procs
###################################
class FakeConsole
    def log_on_timeout_error(message)
        proc do |e|
            binding.pry
            next unless e.is_a?(RexTimeoutError)
            # elog(e)
            puts message + Time.now.to_s
        end
    end

    # sessions --script ...
    def script_context(session)
        session.on_error_proc = log_on_timeout_error('yo, do scripts options here')
        session.run_powershell
    end

    #  sessions --interact ..
    def interact_context(session)
        session.on_error_proc = log_on_timeout_error('yo, do interact options  here')
        # session.on_error_proc = proc do |e|
        #     next unless e.is_a?(RexTimeoutError)
        
        #     puts 'uh oh we timed out - you should run this command instead!' 
        # end
        session.run_powershell
    end

    # sesions -C powerhsell_Exec
    def command_context(session)
        session.on_error_proc = log_on_timeout_error('yo, do commands here')
        session.run_powershell
    end
end

session = Session.new
console = FakeConsole.new
console.interact_context(session)

# begin
#     console.script_context(session)
# rescue => e
#     # noop
#     raise
# end

# begin
#     console.interact_context(session)
# rescue => e
#     # noop
# end

# begin
#     console.command_context(session)
# rescue => e
#     # noop
# end


######################
# second example with more OOP approach
###############################

# class SecondExample
#     def interact
#         @current_mode = 'interactive mode'
#         session = Session.new
#         session.error_handler = self
#         session.run_powershell
#     end

#     def handle_error(e)
#         puts "oh no we exploded in #{@current_mode}!"
#     end
# end


# second_example = SecondExample.new
# second_example.interact



# Other naming convention to possibly consider:
# handle_exception