# RubyRat
A simple and portable RAT made in Ruby

# Getting started

### Compiling the client
In order to compile the client, you must use ruby 2.2.2 (`rvm install 2.2.2 && rvm use 2.2.2`) and run `build_client.sh`.

### `build_client.sh` usage
`build_client.sh <osx,win,l32,l64> <EXENAME>`

 `<osx,win,l32,l64>` are the platforms you can compile for.

 `<EXENAME>` is the final name of the outputted executable.


### Starting the interface
To start the RubyRat interface, just type `./rubyrat`. If you want to run the interface in debug mode, run `./rubyrat DEBUG`. As soon as the interface starts, the server will start listening on port 4567 for connections


# Features
### Current:
- Cross-platform
- Command execution
- Remote file download
- Persistent clients

### Coming
- Reverse shell support (in progress)
- AES encrypted communication
- Module support
- Persistence mechanisms
- Port scanning a host on the client's network

# Built with
- [Atom](https://atom.io)
- All gems in the [Gemfile](https://github.com/cbrnrd/RubyRat/blob/master/Gemfile)

# Disclaimer
This tool is supposed to be used for educational purposes only. I am not personally liable for whatever you use this program for.

# Thank you
Thank you for using RubyRat 👏. If you're feeling generous, donations are always appreciated:


```
19XiyrvqyYNLehf89ckBjPQYCfW77F9rx7 (Ƀ, BTC)
0xf6f247e4a929890926F88144111f5E27d87bD07a (ETH)
LQRUJUpSkmi5BfT6nyPVNKKoLWbnpZ64sL (Ł, LTC)
https://www.paypal.me/0xCB (PayPal)
```
