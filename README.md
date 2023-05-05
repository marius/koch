# Koch

Koch is a tool to install software packages, change files and other things
on a single machine. The changes are described in a file and are written in Ruby.

The file describing a machine should be versioned, that way you create a repeatable
description of how a machine is set up, with history.

For an example of how this can look like, check out this [Rezeptfile](example/Rezeptfile)
and the other files in the directory.

## Notice

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT

Fully **backup** any machine you run this on! This is alpha grade software and
might cause havoc, esp when run with root privileges!
I suggest you use Vagrant to try this out.

## Status

![Tests and Rubocop](https://github.com/marius/koch/actions/workflows/rubocop.yml/badge.svg)

## Philosophy

Koch's configuration files (Rezeptfiles) are just Ruby. All Koch does is provide
a bunch of convenience functions. Feel free to use all the Ruby you want.

## Usage

```
sudo apt -y install git
sudo gem install koch
git clone git@github.com:example/machine.git
cd machine
sudo koch
```

## Supported platforms

  - Ubuntu 22.04 (amd64)
  - Debian 11 (amd64)
  - End of list

## TODO

  - [ ] Interactive mode, ask about each change
  - [ ] publish to rubygems
