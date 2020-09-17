fun! yt#funcs#init()
  let g:yanktools.Funcs = s:Funcs
endfun

let s:v = g:yanktools.vars
let s:Funcs = {}

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:Funcs.default_reg() abort
  " get default register

  let clipboard_flags = split(&clipboard, ',')
  if index(clipboard_flags, 'unnamedplus') >= 0
    return "+"
  elseif index(clipboard_flags, 'unnamed') >= 0
    return "*"
  else
    return "\""
  endif
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:Funcs.get_register(...) abort
  " return default or other register
  let r = a:0 ? a:1 : self.default_reg()
  return [r, getreg(r), getregtype(r)]
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:Funcs.set_register(r, text, type) abort
  " set the register to value, ensure also unnamed is set
  let r = [ a:r, a:text, a:type ]
  let def = self.default_reg()
  let unnamed = def == '"'
  call setreg(r[0], r[1], r[2])
  if !unnamed
    call setreg(r[0], r[1], r[2])
  endif
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:Funcs.store_register(...) abort
  " store current register for later restoring, then return it
  " if setting variables, will be automatically restored on text change
  if !a:0
    let s:v.restoring = 1
    let s:v.has_changed = 1
  endif
  let r = self.default_reg()
  let s:v.stored_register = [r, getreg(r), getregtype(r)]
  return s:v.stored_register
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:Funcs.restore_register() abort
  " s:v.restoring is reset also elsewhere, just in case
  let s:v.restoring = 0
  let r = s:v.stored_register
  call setreg(r[0], r[1], r[2])
  " better an error than restoring the same register twice
  unlet s:v.stored_register
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:Funcs.updatetime(restore) abort
  if exists("##TextYankPost") | return | endif
  if a:restore
    let &updatetime = s:v.updatetime
  else
    let &updatetime = 100
  endif
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:Funcs.msg(txt, ...) abort
  redraw
  exe "echohl" ( !a:0 ? "WarningMsg" : "StorageClass" )
  echo a:txt
  echohl None
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:Funcs.ensure_cursor_moved() abort
  let oldww = &whichwrap
  set whichwrap=h,l
  normal! hl
  let &whichwrap = oldww
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:Funcs.popup(stack) abort
    if has('nvim') && exists('*nvim_open_win')
        silent! call execute('bw '.s:float) " dismiss previous popup

        let txt = split(a:stack.get().text, '\n')
        let s:float = nvim_create_buf(v:false, v:true)
        call nvim_buf_set_lines(s:float, 0, -1, v:true, txt)
        let opts = {'relative': 'cursor', 'width': 80, 'height': len(txt),
                    \ 'col': 0, 'row': 1, 'anchor': 'NW', 'style': 'minimal'}
        let win = nvim_open_win(s:float, 0, opts)
        call setbufvar(s:float, '&filetype', a:stack.get().ft)
        echo printf('[%d/%d] ', a:stack.offset+1, a:stack.size())
        augroup yt_float
            au!
            au CursorMoved * exe 'silent!' s:float . 'bw!'
                        \| exe 'au! yt_float' | aug! yt_float | echo "\r"
        augroup END
        return 1

    elseif exists('*popup_atcursor')
        silent! call popup_close(s:id) " dismiss previous popup

        let title = printf(' [%d/%d] ', a:stack.offset+1, a:stack.size())
        let height = len(split(a:stack.get().text, '\n')) + 4
        let s:id = popup_atcursor(split(a:stack.get().text, '\n'),
                    \{'title': title, 'pos': 'topleft', 'line': 'cursor-'.height,
                    \ 'padding': [1,1,1,1], 'border':[1,1,1,1],
                    \ 'borderchars': [' '], 'borderhighlight': ['PmenuSel'],
                    \})
        call setbufvar(winbufnr(s:id), '&filetype', a:stack.get().ft)
        return 1
    else
        return 0
    endif
endfun

