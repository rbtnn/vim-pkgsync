
let s:subcmd2functions = {
  \ 'init': function('pkgsync#subcmds#init#exec'),
  \ 'list': function('pkgsync#subcmds#list#exec'),
  \ 'install': function('pkgsync#subcmds#install#exec'),
  \ 'uninstall': function('pkgsync#subcmds#uninstall#exec'),
  \ 'update': function('pkgsync#subcmds#update#exec'),
  \ 'clean': function('pkgsync#subcmds#clean#exec'),
  \ 'help': function('pkgsync#subcmds#help#exec'),
  \ }

function! pkgsync#parse_cmdline(args) abort
  let args = a:args
  if 0 < len(args)
    let i = index(keys(s:subcmd2functions), args[0])
    if -1 != i
      call call(s:subcmd2functions[args[0]], [args])
    else
      call pkgsync#error('unknown subcommand: ' .. string(args[0]))
    endif
  else
    call pkgsync#subcmds#help#exec(args)
  endif
endfunction

function! pkgsync#error(text) abort
  throw 'error: ' .. a:text
endfunction

function! pkgsync#output(text) abort
  if exists('g:pkgsync_stdout')
    put=a:text
    print
  else
    echo a:text
  endif
endfunction

function! pkgsync#comp(ArgLead, CmdLine, CursorPos) abort
  let subcmds = keys(s:subcmd2functions)
  let xs = split(a:CmdLine, '\s\+')
  let candidates = []
  let installed_plugins_s = []
  let installed_plugins_o = []

  if filereadable(pkgsync#common#get_config_path())
    let j = json_decode(join(readfile(pkgsync#common#get_config_path()), ''))
    let start_d = get(get(j, 'plugins', {}), 'start', {})
    for user_name in sort(keys(start_d))
      for plugin in start_d[user_name]
        let installed_plugins_s += [printf('%s/%s', user_name, pkgsync#common#get_pluginname(plugin))]
      endfor
    endfor
    let opt_d = get(get(j, 'plugins', {}), 'opt', {})
    for user_name in sort(keys(opt_d))
      for plugin in opt_d[user_name]
        let installed_plugins_o += [printf('%s/%s', user_name, pkgsync#common#get_pluginname(plugin))]
      endfor
    endfor
  endif

  if (1 == len(xs))
    let candidates = subcmds
  else
    if xs[1] == 'install'
      let contains_opt = -1 != index(xs, 'opt')
      let contains_branch = 0 < len(filter(deepcopy(xs), { _,x -> !empty(matchstr(x, '^branch=')) }))
      let candidates = (contains_opt || contains_branch ? [] : ['opt']) + (contains_branch ? [] : ['branch='])
    elseif xs[1] == 'uninstall'
      if 2 == len(xs)
        if a:CmdLine =~# '\s\+$'
          let candidates = empty(installed_plugins_o) ? [] : ['opt']
          for x in installed_plugins_s
            if -1 == index(xs, x)
              let candidates += [x]
            endif
          endfor
        endif
      elseif (3 == len(xs)) || (4 == len(xs))
        if a:CmdLine !~# '\s\+$'
          let candidates = empty(installed_plugins_o) ? [] : ['opt']
        endif
        if (a:CmdLine !~# '\s\+$') || ((3 == len(xs)) && (xs[2] == 'opt'))
          for x in installed_plugins_o
            if -1 == index(xs, x)
              let candidates += [x]
            endif
          endfor
        endif
      endif
    else
      let candidates = subcmds
    endif
  endif

  return sort(filter(candidates, { i,x -> -1 != match(x, a:ArgLead) }), { i1, i2 -> match(i1, a:ArgLead) - match(i2, a:ArgLead) })
endfunction

