### Browser Automation With Selenium

**Selenium** is an open-source test framework that supports testing a wide variety of web applications, including those which make heavy use of AJAX.

When writing test cases, several programming languages are supported, and one of them is Python.  
Let's install Selenium:
```
sudo pip install selenium
# In case pip is not available:
# sudo apt-get install python-pip
```

#### First test case: Testing codepad.org

To get started using Selenium, open a Python interactive console (by running the command `python`) and type:
```
from selenium import webdriver
driver = webdriver.Firefox()
```
The latter command is going to take a few seconds to execute since it's loading a fresh instance of Firefox. Place the newly opened Firefox window and your terminal window side by side, so that you can observe what Selenium does inside Firefox while you give it commands in the terminal.

Load the codepad.org website in Firefox, by running the command:
```
driver.get('http://codepad.org')
```
Select the `Python` radio button on the left-hand side by executing the commands below (which is to say, **not manually**):
```
python_radio_button = driver.find_elements_by_css_selector('input[value=Python]')[0]
python_radio_button.click()
```
Write some code you want codepad.org to execute:
```
text_area = driver.find_element_by_id('textarea')
text_area.send_keys("print 'Hello,' + ' World!'")
```
Click the `Submit` button:
```
submit_button = driver.find_elements_by_name('submit')[0]
submit_button.click()
```
The resulting page should contain the string `Hello, World!`, let's verify this:
```
assert "Hello, World!" in driver.page_source
```
This last command should not output anything, if the test passed. To prove to yourself that this test can indeed fail, try:
```
assert "HelloWorld!" in driver.page_source
```
The test failed, and the failure looks like this:
```
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
AssertionError
```
Finally, close the connection to the browser:
```
driver.quit()
```

#### Second test case: Testing aur.archlinux.org

Try to guess what the following program does, before running it:
```
from selenium import webdriver
from selenium.webdriver.common.keys import Keys

driver = webdriver.Firefox()
driver.get('http://aur.archlinux.org')

search_field = driver.find_element_by_id('pkgsearch-field')
search_field.send_keys('talkpl')
search_field.send_keys(Keys.RETURN)

css_path = 'table.results tr:nth-child(1) > td:nth-child(2) > a'
link_to_click = driver.find_elements_by_css_selector(css_path)[0]
link_to_click.click()

css_path = '#pkginfo tr:nth-child(6) > td'
submitter_td = driver.find_elements_by_css_selector(css_path)[0]
submitter_name = submitter_td.text

assert submitter_name == 'cpcgm'

driver.quit()
```
Run this program. If everything goes right, the `assert` should pass.  
Make it not pass.

#### Third test case: Testing distrowatch.com

Open http://distrowatch.com/ in a new Firefox tab.  
Locate the `Select Distribution` drop-down and select `Arch` from it.  
Result: your browser is being redirected to http://distrowatch.com/table.php?distribution=arch

Your next task is to automate this from within a Selenium test case.

The answer to the question how to do this can easily be found on StackOverflow, but we'll use a more rigorous approach, by enlisting the help of the Selenium IDE.

Search Google for `download selenium IDE`, then choose the topmost link.  
Locate a paragraph that begins with `Download latest released version` and follow the link immediately following this text, which should contain the most recent version number.  
Follow all subsequent instructions to install the Selenium IDE as a Firefox add-on.

After restarting Firefox, locate the `Selenium IDE` icon/button somewhere close to the upper right-hand corner of the browser window.  
Click it and the Selenium IDE window should open.

Notice that the Selenium IDE, once opened, immediately goes into recording mode (you can tell by hovering your mouse over the "dot" button somewhere close to the upper right-hand corner of the application window.

Let's record the sequence of actions we performed previously on distrowatch.com (load the front page, select `Arch`).  
There should now be a `selectAndWait` entry in one of the table views in the Selenium IDE.

From the `File` menu of the Selenium IDE, select `Export Test Case As...`, then `Python 2 / unittest / WebDriver`.  
When prompted for a file name, save the test case as `/tmp/test.py`.

Inspect the contents of file `/tmp/test.py`.  
It should be clear now how to automate the drop-down selection from within a Selenium test case.

Write the complete distrowatch.com test case.  
Your `assert` statement should look like this:
```
assert "Arch Linux" in driver.title
```

#### Fourth test case: Testing a doodle.com poll

Write three complete Selenium test cases for the following poll:  
http://doodle.com/ry3utyr8fzqgzncn

- You should test that, when adding your entry to the poll, setting certain checkboxes results in green checkmarks appearing in the corresponding grid squares after the "Save" operation.
- As well, you should test that the opposite thing happens (with checkboxes that haven't been checked off).
- You should test that removing your entry from the poll works as expected.

#### Fifth test case: Testing an online retailer's website

Who is your favorite online retailer?

Write a complete Selenium test case for a specific product page on your favorite online retailer's website.  
However, your test scenario should begin at the website's main page, and it should use the search function to generate a product listing, and from there it should click on a link to go to a specific product page.  
Your `assert` statement should verify that the product's price is range-bound within specified limits that you set.

