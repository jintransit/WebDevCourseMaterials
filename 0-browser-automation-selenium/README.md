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
Select the `Python` radio button on the left-hand side by executing the commands below.  
**Do not select the radio button manually.** The point is to let the commands below do it.
```
python_radio_button = driver.find_element_by_css_selector('input[value=Python]')
python_radio_button.click()
```
Write some code you want codepad.org to execute:
```
text_area = driver.find_element_by_id('textarea')
text_area.send_keys("print 'Hello,' + ' World!'")
```
Click the `Submit` button (not manually):
```
submit_button = driver.find_element_by_name('submit')
submit_button.click()
```
The subsequent page should contain the string `Hello, World!`, let's verify this:
```
assert 'Hello, World!' in driver.page_source
```
This last command should not output anything, if the test passed. To prove to yourself that this test can indeed fail, try:
```
assert 'HelloWorld!' in driver.page_source
```
The test failed, and the failure looks like this:
```
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
AssertionError
```
The more rigorous approach would be to test that the expected string is not only present, but also located at the correct place within the subsequent page:
```
second_code_div = driver.find_elements_by_css_selector('.code')[1]

results_box = second_code_div.find_elements_by_tag_name('pre')[1]

python_execution_results = results_box.text

assert python_execution_results == 'Hello, World!'
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

print 'Found this submitter name:', submitter_name

assert submitter_name == 'cpcgm'

driver.quit()
```
Run this program. If everything goes right, the `assert` should pass.  
Make it not pass.

#### Third test case: Testing distrowatch.com

Open http://distrowatch.com/ in a new Firefox tab.  
Locate the `Select Distribution` drop-down near the top of the page, and select `Arch` from the list.  
Result: your browser is being redirected to http://distrowatch.com/table.php?distribution=arch

Your next task is to automate this from within a Selenium test case.  
Write the complete distrowatch.com test case.  

Your `assert` statement should verify that the only `h1` tag in the subsequent page contains the expected distro name, `Arch Linux`.

**Hint:** Selecting an entry from a drop-down list requires a special bit of API, like this:
```
# ...
from selenium.webdriver.support.ui import Select
# ...
# drop_down_list = driver.find_element_by_ ...
# Select(drop_down_list).select_by_visible_text('Arch')
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

#### Solution: Testing distrowatch.com
```
from selenium import webdriver
from selenium.webdriver.support.ui import Select

driver = webdriver.Firefox()
driver.get('http://distrowatch.com/')

drop_down_list = \
    driver.find_element_by_css_selector('select[name=distribution]')

Select(drop_down_list).select_by_visible_text('Arch')

distro_name = \
    driver.find_element_by_tag_name('h1').text

print 'Found this distro name:', distro_name

assert distro_name == 'Arch Linux'

driver.quit()
```
#### Solution: Testing a doodle.com poll
```
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.action_chains import ActionChains
import random
from time import sleep

while True:
    print ''
    print 'Setting checkmarks ...'

    driver = webdriver.Firefox()
    driver.get('http://doodle.com/ry3utyr8fzqgzncn')
    sleep(1)

    participant_name_field = driver.find_element_by_id('pname')

    ActionChains(driver) \
    .move_to_element(participant_name_field) \
    .perform()

    body = driver.find_element_by_tag_name('body')
    for _ in range(3):
        sleep(0.5)
        body.send_keys(Keys.ARROW_UP)

    random_name = \
    random.choice('abcdef') + \
    ''.join(random.choice('abcdef0123456789') for i in xrange(15))

    participant_name_field.clear()
    participant_name_field.click()
    participant_name_field.send_keys(random_name)

    set_of_choices_made_by_me = set([])

    for checkmark_index in range(10):
        if random.choice([True,False]) and random.choice([True,False]):
            sleep(0.5)

            driver \
            .find_element_by_id( 'option' + str(checkmark_index) ) \
            .click()

            set_of_choices_made_by_me.add(checkmark_index)

    driver.find_element_by_id('save').click()
    sleep(3)

    driver.quit()

    print ''
    print 'Checkmarks set by me:     ', sorted(list(set_of_choices_made_by_me))

    print ''
    print 'Collecting checkmarks from page ...'

    driver = webdriver.Firefox()
    driver.get('http://doodle.com/ry3utyr8fzqgzncn')

    participant_name_field = driver.find_element_by_id('pname')

    ActionChains(driver) \
    .move_to_element(participant_name_field) \
    .perform()

    body = driver.find_element_by_tag_name('body')
    for _ in range(3):
        sleep(0.5)
        body.send_keys(Keys.ARROW_UP)

    all_participant_rows = driver.find_elements_by_css_selector('tr.participant')

    row_saved_by_me = None
    for p_row in all_participant_rows:
        title = p_row \
                .find_elements_by_css_selector('div.pname')[0] \
                .get_attribute('title')
        if title == random_name:
            row_saved_by_me = p_row
            break

    choices = row_saved_by_me.find_elements_by_css_selector('td.partTableCell')

    set_of_choices_found_on_page = set([])
    for choice_index, choice in enumerate(choices):
        img_list = choice.find_elements_by_tag_name('img')
        if len(img_list) == 1:
            set_of_choices_found_on_page.add(choice_index)

    driver.quit()

    print ''
    print 'Checkmarks found on page: ', sorted(list(set_of_choices_found_on_page))

    print ''
    if set_of_choices_found_on_page == set_of_choices_made_by_me:
        print 'Test passed.'
    else:
        print 'Test failed.'

    assert set_of_choices_found_on_page == set_of_choices_made_by_me
```

