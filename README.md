# TeXify online

## require

`ruby`

ensure you have installed `xelatex`

## start

	$ ./texify-online.rb

and it will start on port 2000

## how to use

The server accept only two methods, GET and POST
You will GET a guidance page to upload you file

### POST

post from http by `multipart/form-data `

#### File types

##### ZIP

you should ensure that you zip contains a tex file or it contains a folder which contains a tex source file.

##### TeX Source file

a isolated TeX source file can also work, but no other resources relied.

### Operation

- By html web page, choose the file and click submit
- by `curl` like this `curl -v --form file=@hello.tex localhost:2000`  **DON’T SUPPOT NOW**# texify-online