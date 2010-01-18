module Wn
  module Commands
    
    # Deploys the application to Webbynode
    def push
      unless dir_exists(".git")
        log "Not an application or missing initialization. Use 'webbynode init'."
        return
      end

      log "Publishing #{app_name} to Webbynode..."
      run "git push webbynode master"
    end
    
    # Initializes the Repository and adds Webbynode to the remote
    # Adds a populated the .gitignore file
    # Creates the .pushand file and sets permissions on it
    # Determines what the [dns]/[host] will be, depending on user's arguments
    # Will default to the applications folder name if the [dns]/[host] is not specified
    def init
      # if params.size < 1
      #   # TODO
      #   # Add a template with all commands (when more are available)
      #   log_and_exit "usage: webbynode init webby_ip [host]"
      # end

      webby_ip, host = *options
      host = app_name unless host

      unless file_exists(".pushand")
        log "Initializing deployment descriptor for #{host}..."
        create_file ".pushand", "#! /bin/bash\nphd $0 #{host}\n"
        run "chmod +x .pushand"
      end

      unless file_exists(".gitignore")
        log "Creating .gitignore file..."
        create_file ".gitignore", File.open(File.join(templates_path, 'gitignore')).read
      end

      if dir_exists(".git")
        log "Adding Webbynode remote host to git..."
      else
        log "Initializing git repository..."
      end

      git_init webby_ip
    end

    def git_init(ip)
      run "git init" unless dir_exists(".git")
      run "git remote add webbynode git@#{ip}:#{app_name}"
      run "git add ."
      run "git commit -m \"Initial commit\""
    end
  
  end
end