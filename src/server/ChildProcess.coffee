path = Npm.require 'path'

@practical ?= {}

class practical.ChildProcess

  child: null

  descendants: []

  pipe : null

  command: null

  killed: false

  @_spawn = Npm.require('child_process').spawn

  constructor:->
    log.debug "ChildProcess.constructor()"

  spawn: (command, args=[], options={}, pipeClass = null)->
    log.debug "ChildProcess.spawn()", arguments

    expect(@child,"ChildProcess is already running").to.be.null
    expect(command,"Invalid command argument").to.be.a "string"
    expect(args,"Invalid args argument").to.be.an "array"
    expect(options,"Invalid options argument").to.be.an "object"

    @command = path.basename command

    log.debug("spawning #{@command}")

    process.on 'exit', (code)=>
      log.debug "ChildProcess.process.on 'exit': @command=#{@command} @killed=#{@killed} code=#{code}"
      @kill()

    @child = practical.ChildProcess._spawn(command, args, options)

#    if pipeClass
#      @pipe = new pipeClass(@child.stdout, @child.stderr)
#    else
#      @pipe = new practical.Pipe(@child.stdout, @child.stderr)

    @child.on "exit", (code, signal)=>
      log.debug "ChildProcess.process.on 'exit': @command=#{@command} @killed=#{@killed} code=#{code} signal=#{signal}"
      @killed = true
      if code?
        log.info "#{command} exited with code: #{code}"
      else if signal?
        log.info "#{command} killed with signal: #{signal}"
      else
        log.error "#{command} exited with arguments: #{arguments}"


  kill: (signal = "SIGPIPE")->
    log.debug "ChildProcess.kill() signal=#{signal} @command=#{@command} @killed=#{@killed}"
    return if @killed
    log.info "killing", @command
    @killed = true
    try
      # Providing a negative pid will kill the entire process group,
      # i.e. the process and all it's children
      # See man kill for more info
      #process.kill(-@child.pid, signal)
      @child?.kill(signal)

    catch err
      log.warn "Error: While killing #{@command} with pid #{@child.pid}:\n", err
