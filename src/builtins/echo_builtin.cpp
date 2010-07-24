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

int echo_builtin::exec(vector<string> bash_args)
{
  //figure out just what the options are
  bool suppress_nl=newline_suppressed(bash_args);
  bool escape_enabled=enable_escapes(bash_args);
  if (escape_enabled)
  {
    replace_escapes(bash_args);
  }
  for (int i=0; i<bash_args.size(); ++i)
  {
    OUTPUT_BUF << bash_args[i];
  }
  if (!suppress_nl)
  {
    OUTPUT_BUF << std::endl;
  }
  return 0;
}

bool echo_builtin::newline_suppressed(vector<string> &args)
{
  bool suppressed=false;
  for (int i=0; i<args.size(); i++)
  {
    if (args[i].compare("-n")==0)
    {
      args.erase(args.begin()+i);
      i--;
      suppressed=true;
    }
    else if (args[i].find("\\c")!=std::string::npos)
    {
      suppressed=true;
      replace_all(args[i], "\\c", "");
    }
  }
  return suppressed;
}

bool echo_builtin::enable_escapes(vector<string> &args)
{
  bool enable=false;
  for (int i=0; i<args.size(); i++)
  {
    if (args[i].compare("-e")==0)
    {
      enable=true;
      args.erase(args.begin()+i);
      i--;
    }
    else if (args[i].compare("-E")==0)
    {
      enable=false;
      args.erase(args.begin()+i);
      i--;
    }
  }
  return enable;
}

void echo_builtin::replace_escapes(vector<string> &args)
{
  for (int i=0; i<args.size(); i++)
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

void echo_builtin::replace_all(string &word, const string &to_rep, const string &rep)
{
  while (word.find(to_rep)!=std::string::npos)
  {
    word.replace(word.find(to_rep),to_rep.size(),rep);
  }
}

void echo_builtin::replace_numeric_escapes(string &word)
{
  //start with octals
  string octal_dig="12345670";
  string hex_dig="123456789aAbBcCdDeEfF0";
  while (word.find("\\0")!=std::string::npos)
  {
    string octal_num;
    for (int i=2; i<=4; i++)
    {
      if(octal_dig.find(word[word.find("\\0")+i])!=string::npos)
      {
        octal_num+=word[word.find("\\0")+i];
      }
    }
    int a=std::strtol(octal_num.c_str(),NULL,8);
    string replace_str;
    replace_str+=(char)a;
    word.replace(word.find("\\0"),2+octal_num.size(), replace_str);
  }
  //move on up to the hex numbers
  while (word.find("\\x")!=std::string::npos)
  {
    string hex_num;
    for (int i=2; i<=3; i++)
    {
      if(hex_dig.find(word[word.find("\\x")+i])!=string::npos)
      {
        hex_num+=word[word.find("\\x")+i];
      }
    }
    int a=std::strtol(hex_num.c_str(),NULL,16);
    string replace_str;
    replace_str+=(char)a;
    word.replace(word.find("\\x"),2+hex_num.size(), replace_str);
  }
}
