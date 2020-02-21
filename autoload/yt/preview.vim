let s:Y = g:yanktools.yank
let s:v = g:yanktools.vars
let s:F = g:yanktools.Funcs

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#preview#start() abort
  if s:Y.is_empty() | return | endif
  call s:Y.synched()
  call yt#preview#show(1)
endfunction

" s:v.pwwin          original window number
" s:v.pwline         line of the original buffer, close preview if this changes
" s:v.pwsidebuf      bufnr of the side buffer, where the stack is displayed
" s:v.pwsidebufwin   winnr of the side buffer
" s:cursPos          before leaving th original buffer, highlight the cursor
"                    position, to show where a paste will be inserted

function! yt#preview#show(sidebuf) abort
  if !exists('s:v.pwwin')
    " just starting from a regular buffer
    let s:v.lz = &lazyredraw | set lz
    let s:v.pwwin  = winnr()
    let s:v.pwline = line('.')
    if a:sidebuf
      let s:cursPos = matchaddpos('DiffText', [[line('.'), virtcol('.')]])
    endif
  endif

  " open or refresh the preview
  call s:preview()
  if a:sidebuf
    call s:sidebuf()
  elseif exists('s:v.pwsidebuf')
    exe 'noautocmd' s:v.pwsidebufwin . 'wincmd w'
    exe "noautocmd normal! \<c-w>50|"
  else
    exe 'noautocmd' s:v.pwwin . 'wincmd w'
  endif
  call s:autocmd()
endfunction

function! s:preview() abort
  " open the preview with the current stack offset
  " close any previous open preview, first
  pclose!
  let item = s:Y.get()
  let text = split(item.text, '\n')
  let nl = len(text) < 15 ? len(text) : 15

  " decide the window height
  if exists('s:v.pwsidebuf')    " sidebuf is open: no change
    noautocmd rightbelow vnew
  elseif exists('s:cursPos')    " sidebuf will open: set to 15
    noautocmd botright 15new
  else                          " not using sidebuf: use text lines (max 15)
    exe "noautocmd botright" nl."new"
  endif
  setlocal bt=nofile bh=wipe noswf nobl
  setlocal previewwindow
  let pos = (s:Y.offset+1).'/'.s:Y.size()
  let &l:statusline = '%#Visual# Pos. '.pos.'  %#Tabline# ft ' . item.ft
  silent put =text
  1d _
  1
  exe 'setf' item.ft
  setlocal noma
endfunction

function! s:sidebuf() abort
  " open the side buffer, with the list of the stack items
  noautocmd leftabove vnew
  exe "noautocmd normal! \<c-w>50|"
  setlocal bt=nofile bh=wipe noswf nobl nonu signcolumn=yes
  let &l:statusline = '%#Tabline#'

  " fill the buffer with the stack items, then delete the first empty line
  for yank in s:Y.stack
    silent put =strtrans(yank.text)
  endfor
  1d _
  setlocal noma

  " add the sign to the line of the current offset, then go to it
  let s:v.pwsidebufwin = winnr()
  let lnum = s:Y.offset + 1
  if !exists('s:v.pwsidebuf')
    sign define ytoff text=> texthl=WarningMsg
    let s:v.pwsidebuf = bufnr('%')
  endif
  exe ":sign place 1 line=" . lnum . " name=ytoff buffer=" . s:v.pwsidebuf
  exe 'normal!' lnum.'G'
  call s:maps()
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:maps() abort
  nnoremap <nowait><buffer><silent> q     :call yt#preview#close()<cr>
  nmap     <nowait><buffer><silent> j     :<c-u>call <sid>next(v:count1)<cr>
  nmap     <nowait><buffer><silent> k     :<c-u>call <sid>prev(v:count1)<cr>
  nmap     <nowait><buffer><silent> J     :<c-u>call <sid>last()<cr>
  nmap     <nowait><buffer><silent> K     :<c-u>call <sid>first()<cr>
  nmap     <nowait><buffer><silent> <cr>  :<c-u>call <sid>update_line()<cr>
  nmap     <nowait><buffer>         p     <tab>p
  nmap     <nowait><buffer>         P     <tab>P
  nmap     <nowait><buffer>         [p    <tab><Plug>(PasteIndent_p)
  nmap     <nowait><buffer>         ]p    <tab><Plug>(PasteIndent_P)
  nmap     <nowait><buffer>         ]y    j
  nmap     <nowait><buffer>         [y    k
  nmap     <nowait><buffer>         ]Y    J
  nmap     <nowait><buffer>         [Y    K
  nmap     <nowait><buffer>         i     <Plug>(InteractivePaste)
  nnoremap <nowait><buffer><silent> <tab> :exe g:yanktools.vars.pwwin.'wincmd w'<cr>
endfunction

function! s:can_close_preview() abort
  if !( &previewwindow || exists('s:v.pwsidebuf') && bufnr('%') == s:v.pwsidebuf )
        \ && line('.') != s:v.pwline
    call yt#preview#close()
  endif
endfunction

function! s:autocmd(...) abort
  augroup yanktools_preview
    au!
    au TabLeave    * call yt#preview#close()
    au CursorMoved * call s:can_close_preview()
  augroup END
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#preview#update() abort
  if s:v.pwline
    call yt#preview#show(0)
    call s:goto_offset()
  endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#preview#close()
  if s:v.pwline
    pclose!
    autocmd! yanktools_preview
    augroup! yanktools_preview
    let s:v.pwline = 0
    if exists('s:v.pwsidebuf')
      exe "sign unplace * buffer=" . s:v.pwsidebuf
      sign undefine ytoff
      exe s:v.pwsidebuf . 'bw'
      unlet s:v.pwsidebuf
      unlet s:v.pwsidebufwin
    endif
    exe s:v.pwwin . 'wincmd w'
    if exists('s:cursPos')
      call matchdelete(s:cursPos)
      unlet s:cursPos
    endif
    unlet s:v.pwwin
    let &lazyredraw = s:v.lz
  endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:goto_offset() abort
  let ln = s:Y.offset + 1
  exe 'normal!' ln.'G'
  call s:update_sign()
endfun

fun! s:next(count) abort
  exe "normal ".a:count."\<Plug>(YankNext)"
  call s:goto_offset()
endfun

fun! s:prev(count) abort
  exe "normal ".a:count."\<Plug>(YankPrevious)"
  call s:goto_offset()
endfun

fun! s:first() abort
  exe "normal \<Plug>(YankFirst)"
  call s:goto_offset()
endfun

fun! s:last() abort
  exe "normal \<Plug>(YankLast)"
  call s:goto_offset()
endfun

fun! s:update_line() abort
  let s:Y.offset = line('.') - 1
  call yt#preview#show(0)
  call s:update_sign()
endfun

fun! s:update_sign() abort
  exe "sign unplace * buffer=" . s:v.pwsidebuf
  exe "sign place 1 line=" . line('.') . " name=ytoff buffer=" . s:v.pwsidebuf
endfun
