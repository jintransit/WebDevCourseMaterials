## Web scraping

Web scraping is a technique for the automated extraction of useful information from HTML documents.

### Ingredients

We need the **nokogiri** RubyGem.  
Nokogiri is a library that makes it very easy to parse HTML pages using CSS style syntax.

### Scenario 1:  
#### We want the fully qualified CSS selector of a DOM element based on its tag name and content

```
require 'nokogiri'
require 'open-uri'

doc = Nokogiri::HTML(open("https://aur.archlinux.org/packages/syncany-bzr/"))

doc.css("td").each do |td|
  if td.content == "dserban"
    puts td.css_path
  end
end

# html > body > div:nth-of-type(2) > div:nth-of-type(4) > table > tr:nth-of-type(5) > td
```

### Scenario 2:  
#### We want the content of a DOM element based on a CSS selector

```
require 'nokogiri'
require 'open-uri'

doc = Nokogiri::HTML(open("https://aur.archlinux.org/packages/syncany-bzr/"))

td_css_path = "html > body > div:nth-of-type(2) > div:nth-of-type(4) > table > tr:nth-of-type(5) > td"

doc.css(td_css_path).each do |td|
  puts td.content
end

# dserban
```

### Changing the user agent

The `open(urltext)` method we use in `Nokogiri::HTML()` can also take a hash of header information.  
This may be necessary because the site you are scraping content from has been set up to block bots by checking user agent headers.  
You can use **whatsmyuseragent.com** to figure out the user agent you would like to use, and then pass `open(urltext, header_info_hash)` to `Nokogiri::HTML()` like this:

```
doc = Nokogiri::HTML(open("http://whatsmyuseragent.com/", "User-Agent" => "Mozilla Firefox"))
```

### Pro Tip:

**Do not abuse this technique.**  
A reasonable use case would be to issue one GET request every 300 seconds or more.

