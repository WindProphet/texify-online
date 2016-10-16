# TeXify online

## require

`ruby`

ensure you have installed `xelatex`

	yum install -y git ruby unzip texlive-*
	git clone git://github.com/WindProphet/texify-online
	cd texify-online && ./texify-server.rb

## start

	$ ./texify-online.rb [port=2000]

and it will start on port 2000

## how to use

The server accept only two methods, GET and POST
You will GET a guidance page to upload you file

### POST

post from http by `multipart/form-data `

#### File types

##### ZIP

you should ensure that you zip contains a tex file or it contains a folder which contains a tex source file.

**ERROR** Some ZIP cannot dealt successfully

##### TeX Source file

a isolated TeX source file can also work, but no other resources relied.

### Operation

- By html web page, choose the file and click submit
- by `curl` like this `curl -v --form file=@hello.tex localhost:2000`  **DON’T SUPPOT NOW**
