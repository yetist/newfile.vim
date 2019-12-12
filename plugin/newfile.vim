" File: newfile.vim
" Summary: This is plugin for vim to autogen the new file.
" Author: yetist <yetist@gmail.com>
" URL: http://gsnippet.googlecode.com/svn/trunk/vim-plugins/newfile.vim
" License:
"
" This program is free software; you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation; either version 2 of the License, or
" (at your option) any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License along
" with this program; if not, write to the Free Software Foundation, Inc.,
" 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
"
" Version: Tue, 18 Dec 2007 09:55:16 +0800
" Usage: this file will auto run when you create a new file.
" But you also can run it from command, do :py newfile()
"
"You can use these tags below for your file template:
"[LICENSE] [_H_] [DESCRIPTION] [COPYRIGHT] [AUTHOR] [BASENAME] [FILENAME]
"[YEAR] [DATE] [EXTNAME] [EMAIL]
"
"
if !has('python')
	finish
endif

function! CreateNewFile()
python << EOF
# -*- coding: utf-8 -*-
import vim, os, time

DESCRIPTION = "This file is part of ____"

COPYRIGHT = "Copyright (C) [YEAR] [AUTHOR] <[EMAIL]>"

GPL="""This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
"""
##############################################

HEAD = {}
TAIL = {}

HEAD[".c"] = """/* vi: set sw=4 ts=4 sts=4 expandtab wrap ai: */
/*
 * [FILENAME]: [DESCRIPTION]
 *
 * [COPYRIGHT]
 *
[LICENSE]
 * */
"""
TAIL[".c"]= ""

HEAD[".h"] = HEAD[".c"] + """
#ifndef [_H_]
#define [_H_]  1

G_BEGIN_DECLS

"""

TAIL[".h"] = """
G_END_DECLS

#endif /* [_H_] */
""" + TAIL[".c"]

HEAD[".m"] = """/* vi: set sw=4 ts=4 sts=4 expandtab wrap ai: */
/*
 * [FILENAME]: [DESCRIPTION]
 *
 * [COPYRIGHT]
 *
[LICENSE]
 * */
"""
TAIL[".m"]= """"""
"""
/*
vi:ts=4:wrap:ai:expandtab
*/
"""

HEAD[".py"] = """#! /usr/bin/env python
# -*- encoding:utf-8 -*-
# FileName: [FILENAME]

"[DESCRIPTION]"

__author__   = "[AUTHOR]"
__copyright__= "[COPYRIGHT]"
__license__  = \"\"\"[LICENSE]\"\"\"
"""

TAIL[".py"]="""
if __name__=="__main__":
    pass
"""

HEAD[".vim"] ="""" File: [FILENAME]
" Summary: This is a plugin for vim to ...
" Author: [AUTHOR] <[EMAIL]>
" URL: [URL]
" License:
[LICENSE]
" Version: [DATE]
" Usage: do :
" Customization:
"
"""

def get_author():
    ret = {}
    if vim.eval("exists('g:author_name')") == "1":
        ret["name"] = vim.eval("g:author_name")
    else:
        ret["name"] = os.environ['USER']
    if vim.eval("exists('g:author_email')") == "1":
        ret["email"] = vim.eval("g:author_email")
    else:
        ret["email"] = "%s@%s" % (ret["name"], os.uname()[1])
    if vim.eval("exists('g:author_url')") == "1":
        ret["url"] = vim.eval("g:author_url")
    else:
        ret["url"]= "http://none"
    if vim.eval("exists('g:author_blog')") == "1":
        ret["blog"] = vim.eval("g:author_blog")
    else:
        ret["blog"]= "http://none"
    return ret

def write_header(lines):
    vim.current.buffer[0:0] = lines.splitlines()

def write_tail(lines):
    for line in lines.splitlines():
        vim.current.buffer.append(line)

def newfile():
    author = get_author()
    info={}
    info["author"] = author["name"]
    info["email"] = author["email"]
    info["url"] = author["url"]
    info["year"] = time.strftime("%Y")
    info["date"] = time.strftime("%Y-%m-%d %H:%M:%S")
    info["filename"] = vim.eval("expand(\"%:t\")")
    (info["basename"], info["extname"]) = os.path.splitext(info["filename"])
    info["_h_"] = "__"+"_".join(info["basename"].upper().split("-"))+"_H__"

    for k in info.keys():
        COPYRIGHT.replace("["+k.upper()+"]", info[k])
    info["copyright"] = COPYRIGHT

    for k in info.keys():
        DESCRIPTION.replace("["+k.upper()+"]", info[k])
    info["description"] = DESCRIPTION

    #########################################################################

    c_gpl = "\n".join([" * " + i for i in GPL.splitlines()]).replace("\n * \n","\n *\n")
    vim_gpl = "\n".join(["\" " + i for i in GPL.splitlines()]).replace("\" \n","\"\n")
    if info["extname"] == ".c" or info["extname"] == ".h" or info["extname"] == ".m":
        info["license"] = c_gpl
    elif info["extname"] == ".vim":
        info["license"] = vim_gpl
    else:
        info["license"] = GPL

    if HEAD.has_key(info["extname"]):
        for k in info.keys():
            HEAD[info["extname"]] = HEAD[info["extname"]].replace("["+k.upper()+"]", info[k])
        write_header(HEAD[info["extname"]])
    if TAIL.has_key(info["extname"]):
        for k in info.keys():
            TAIL[info["extname"]] = TAIL[info["extname"]].replace("["+k.upper()+"]", info[k])
        write_tail(TAIL[info["extname"]])

if __name__=="__main__":
    newfile()
EOF
endfunc

command! -nargs=0 NewFile call CreateNewFile()

if has("autocmd")
        augroup newfile
                autocmd BufNewFile *.*  exec("NewFile")
        augroup END
endif " has("autocmd")
