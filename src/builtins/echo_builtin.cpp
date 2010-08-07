/*
Copyright 2010 Nathan Eloe

This file is part of libbash.

libbash is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

libbash is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with libbash.  If not, see <http://www.gnu.org/licenses/>.
*/
///
/// \file echo_builtin.cpp
/// \author Nathan Eloe
/// \brief class that implements the echo builtin
///

#include "echo_builtin.h"

echo_builtin::echo_builtin(std::ostream &outstream, std::ostream &errstream, std::istream&instream) : cppbash_builtin(outstream, errstream, instream)
{
}

int echo_builtin::exec(std::vector<std::string> bash_args)
{
  //figure out just what the options are
	bool suppress_nl;
	bool escapes_enabled;
	determine_options(bash_args, suppress_nl, escapes_enabled);
  if (escapes_enabled)
  {
		suppress_nl = (suppress_nl || newline_suppressed(bash_args));
    replace_escapes(bash_args);
  }
	std::copy(bash_args.begin(), bash_args.end()-1, std::ostream_iterator<std::string>(this->out_buffer()," "));
	this->out_buffer() << *(bash_args.end()-1);
	if (!suppress_nl)
  {
    this->out_buffer() << std::endl;
  }
  return 0;
}

void echo_builtin::determine_options(std::vector<std::string> &args, bool &suppress_nl, bool &enable_escapes)
{
	enable_escapes=false;
	suppress_nl=false;
	bool sup_nl=false;
	bool en_esc=false;
	bool real_opts;
	for (int i=0; i<args.size(); i++)
	{
		if (*(args[i].begin()) == '-')
		{
			real_opts=true;
			for (std::string::iterator j = args[i].begin()+1; j != args[i].end(); j++)
			{
				if (*j=='n')
				{
					sup_nl=true;
				}
				else if (*j=='e')
				{
					en_esc=true;
				}
				else if (*j=='E')
				{
					en_esc=false;
				}
				else
				{
					real_opts=false;
				}
			}
			if (real_opts)
			{
				args.erase(args.begin()+i);
				i--;
				suppress_nl=sup_nl;
				enable_escapes=en_esc;
			}
		}
		else
		{
			i=args.size();
		}
	}
}

bool echo_builtin::newline_suppressed(std::vector<std::string> &args)
{
  bool suppressed = false;
	for (int i = 0; i < args.size(); i++)
	{
		while (args[i].find("\\c")!=std::string::npos)
		{
			suppressed = true;
			replace_all(args[i], "\\c", "");
		}
	}
  return suppressed;
}

void echo_builtin::replace_escapes(std::vector<std::string> &args)
{
  for (int i = 0; i<args.size(); i++)
  {
    replace_all(args[i],"\\a","\a");
    replace_all(args[i],"\\b","\b");
    replace_all(args[i],"\\e","\e");
    replace_all(args[i],"\\f","\f");
    replace_all(args[i],"\\n","\n");
    replace_all(args[i],"\\r","\r");
    replace_all(args[i],"\\t","\t");
    replace_all(args[i],"\\v","\v");
    replace_all(args[i],"\\\\","\\");
    replace_numeric_escapes(args[i]);
  }
}

void echo_builtin::replace_all(std::string &word, const std::string &to_rep, const std::string &rep)
{
  while (word.find(to_rep) != std::string::npos)
  {
    word.replace(word.find(to_rep),to_rep.size(),rep);
  }
}

void echo_builtin::replace_numeric_escapes(std::string &word)
{
  //start with octals
  std::string octal_dig = "12345670";
  std::string hex_dig = "123456789aAbBcCdDeEfF0";
  while (word.find("\\0")!=std::string::npos)
  {
    std::string octal_num;
    for (int i = 2; i <= 4; i++)
    {
      if(octal_dig.find(word[word.find("\\0") + i]) != std::string::npos)
      {
        octal_num += word[word.find("\\0")+i];
      }
    }
    int a=std::strtol(octal_num.c_str(),NULL,8);
    std::string replace_str;
    replace_str += (char)a;
    word.replace(word.find("\\0"),2 + octal_num.size(), replace_str);
  }
  //move on up to the hex numbers
  while (word.find("\\x")!=std::string::npos)
  {
    std::string hex_num;
    for (int i = 2; i <= 3; i++)
    {
      if(hex_dig.find(word[word.find("\\x")+i]) != std::string::npos)
      {
        hex_num += word[word.find("\\x")+i];
      }
    }
    int a=std::strtol(hex_num.c_str(),NULL,16);
    std::string replace_str;
    replace_str += (char)a;
    word.replace(word.find("\\x"),2+hex_num.size(), replace_str);
  }
}
