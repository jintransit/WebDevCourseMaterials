################################################################

Create your first HTML file and place it in a newly created directory.  
Copy the lines below; paste them into a new file `index.html`.

```
<!DOCTYPE html>
<html>
<head>
<title>My Awesome Web Page</title>
</head>
<body>
<div>This is the top section.</div>
<div>This is the actual page content.</div>
<div>This is the bottom section.</div>
</body>
</html>
```

################################################################

Run this command in the same directory where you placed the file:
```
python -m SimpleHTTPServer
```

Point your browser at `http://127.0.0.1:8000/`.

Let's play with some colors; this is done in two steps.  
First of all, give your content some classes.

```
<!DOCTYPE html>
<html>
<head>
<title>My Awesome Web Page</title>
</head>
<body>
<div class="shownupabove">This is the top section.</div>
<div class="showninthecenter">This is the actual page content.</div>
<div class="showndownbelow">This is the bottom section.</div>
</body>
</html>
```

Hit "Refresh"/F5 in the browser to reload the HTML content.

The separation between document structure (HTML/markup) and visual representation (CSS/style)
is a fundamental principle of web design (sometimes called "separation of concerns").  
It is the reason why we need to break up the current operation into two steps.

################################################################

Having decorated our markup with CSS classes, we are now ready to associate some visual style to those classes.  
This is done by adding a `<style>` tag to our `<head>` section.

```
<!DOCTYPE html>
<html>
<head>
<title>My Awesome Web Page</title>
<style>
.shownupabove {
  background-color: #0000FF;
}
.showninthecenter {
  background-color: #9999FF;
}
.showndownbelow {
  background-color: #0000FF;
}
</style>
</head>
<body>
<div class="shownupabove">This is the top section.</div>
<div class="showninthecenter">This is the actual page content.</div>
<div class="showndownbelow">This is the bottom section.</div>
</body>
</html>
```

Hit "Refresh"/F5 in the browser to see the changes.  
One thing you'll notice is that it is very hard to read black text on a blue background.
This is very easy to fix.

################################################################

In addition to the CSS property called `background-color` we also need to specify `color`.  
White on blue is easy to read, so let's make the text white up above and down below.  
At the same time, let's bold the text up above and let's make the text down below a slightly smaller font size.  
Also, let's give the text some breathing room inside those `<div>` boxes.

```
<!DOCTYPE html>
<html>
<head>
<title>My Awesome Web Page</title>
<style>
.padded {
  padding: 10px;
}
.shownupabove {
  background-color: #0000FF;
  color: white;
  font-weight: bold;
}
.showninthecenter {
  background-color: #9999FF;
}
.showndownbelow {
  background-color: #0000FF;
  color: white;
  font-size: 80%;
}
</style>
</head>
<body>
<div class="padded shownupabove">This is the top section.</div>
<div class="padded showninthecenter">This is the actual page content.</div>
<div class="padded showndownbelow">This is the bottom section.</div>
</body>
</html>
```

################################################################

A good practice in web development is to factor out the CSS code into its own file, so let's do that.  
In the same location where you saved your HTML file, please create an empty file called `style.css`.  
Copy all text between the `<style>` and `</style>` tags; paste it into the newly created CSS file.  
Your HTML file should now look like this:

```
<!DOCTYPE html>
<html>
<head>
<title>My Awesome Web Page</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<div class="padded shownupabove">This is the top section.</div>
<div class="padded showninthecenter">This is the actual page content.</div>
<div class="padded showndownbelow">This is the bottom section.</div>
</body>
</html>
```

Notice we are now referencing the CSS file in the `<head>` section.

################################################################

We are now going to add some behavior to our little web page.  
The simplest example of scripted behavior in a web page is to show a popup box with some text.  
Add a `<script>` section at the end of your page, like this:

```
<!DOCTYPE html>
<html>
<head>
<title>My Awesome Web Page</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<div class="padded shownupabove">This is the top section.</div>
<div class="padded showninthecenter">This is the actual page content.</div>
<div class="padded showndownbelow">This is the bottom section.</div>
</body>
</html>
<script>
  alert("JavaScript executed successfully");
</script>
```

################################################################

Let's now factor out the JavaScript code into its own file, just like we did with our CSS code.  
In the same location where you saved your HTML file, please create an empty file called `app.js`.  
Copy the one line between the `<script>` and `</script>` tags; paste it into the newly created JS file.  
Your HTML file should now look like this:

```
<!DOCTYPE html>
<html>
<head>
<title>My Awesome Web Page</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<div class="padded shownupabove">This is the top section.</div>
<div class="padded showninthecenter">This is the actual page content.</div>
<div class="padded showndownbelow">This is the bottom section.</div>
</body>
</html>
<script src="app.js"></script>
```

Notice how our little project now cleanly separates:  
- structure / markup (HTML file)  
- visuals (CSS file)  
- behavior (JS file)  

This is a very good habit to develop early on for those who aim to become web professionals.

################################################################

At this point in our project, our JavaScript code executes without user interaction, as soon as the page is fully loaded in the browser.  
However, JavaScript is most useful when it executes in response to a user's gestures.  
To achieve this, we are going to use JavaScript functions.  
Your `app.js` should now look like this:

```
function showAlertPopup()
{
  alert("JavaScript executed successfully");
}
```

To prove to yourself that the JavaScript code now no longer executes automatically, refresh your page in the browser.  
You should no longer see the alert popup.

################################################################

There are many ways to have a JavaScript function execute in response to a user's gestures; we are only going to use two.  
We are going to add one more `<div>` to the bottom of the `<body>` section of our HTML file, like this:

```
<!DOCTYPE html>
<html>
<head>
<title>My Awesome Web Page</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<div class="padded shownupabove">This is the top section.</div>
<div class="padded showninthecenter">This is the actual page content.</div>
<div class="padded showndownbelow">This is the bottom section.</div>
<div class="padded"><a href="javascript:showAlertPopup();">Click me to see the popup!</a></div>
</body>
</html>
<script src="app.js"></script>
```

Refresh your page and test the newly defined behavior.

################################################################

Until now, we have used JavaScript's `alert` function to make sure our split-file setup works correctly.  
Now we'd like to have JavaScript do something useful or interesting for us.  
Probably one of the more interesting things we can do with JavaScript is to hide/show elements of our page in response to user interaction.  
The first step we need to take to make that happen is to give each `<div>` its own ID, in order to make these divs targetable by JavaScript code.  
Remember: classes are for CSS, IDs are for JavaScript. (Mostly.)  
With IDs, your HTML file is going to look like this:

```
<!DOCTYPE html>
<html>
<head>
<title>My Awesome Web Page</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<div id="upabove" class="padded shownupabove">This is the top section.</div>
<div id="inthecenter" class="padded showninthecenter">This is the actual page content.</div>
<div id="downbelow" class="padded showndownbelow">This is the bottom section.</div>
<div id="linkthatshowspopup" class="padded"><a href="javascript:showAlertPopup();">Click me to see the popup!</a></div>
</body>
</html>
<script src="app.js"></script>
```

################################################################

The second step will be to load Zepto.JS, a JavaScript library which will make us more productive when coding web application behavior.

```
<!DOCTYPE html>
<html>
<head>
<title>My Awesome Web Page</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<div id="upabove" class="padded shownupabove">This is the top section.</div>
<div id="inthecenter" class="padded showninthecenter">This is the actual page content.</div>
<div id="downbelow" class="padded showndownbelow">This is the bottom section.</div>
<div id="linkthatshowspopup" class="padded"><a href="javascript:showAlertPopup();">Click me to see the popup!</a></div>
</body>
</html>
<script src="http://webdev.rosedu.org/js/zepto.min.js"></script>
<script src="app.js"></script>
```

################################################################

Refresh your page and press F12 in Chromium (you must be using Chromium or Chrome for this exercise, however be aware that Firefox also provides the same tools and features, although through a different UI.)  
Select `Console` in the toolbar.
At the prompt, type:

```
$("#linkthatshowspopup").hide();
```

... and press Enter.  
Notice how the most recently added `<div>` has been removed from the page.  
Also note that your markup is no longer identical to the one you typed into your HTML file; Zepto.JS has added a `style` attribute like this:

```
<div id="linkthatshowspopup" class="padded" style="display: none;">
```

whereas in your original markup you had typed:

```
<div id="linkthatshowspopup" class="padded">
```

We therefore conclude that Zepto.JS hides our `<div>` by giving it an inline CSS property of:

```
display: none;
```

We can take advantage of this little fact and build an application that navigates between different "visual states" by hiding the current one and showing the next.

################################################################

We need to make sure that all of our interesting visual states (divs actually) are hidden by default when our HTML page loads.  
Also, we are going to add the "visualstate" class to each visual state (div) in our HTML file:

```
<!DOCTYPE html>
<html>
<head>
<title>My Awesome Web Page</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<div>
<button onclick="javascript:firstHideAllVisualStatesThenShowTopSection();">Show the top section</button>
<button onclick="javascript:firstHideAllVisualStatesThenShowPageContent();">Show the actual page content</button>
<button onclick="javascript:firstHideAllVisualStatesThenShowBottomSection();">Show the bottom section</button>
<button onclick="javascript:firstHideAllVisualStatesThenShowLinkToPopup();">Show link to popup</button>
<button onclick="javascript:showAllVisualStates();">Show everything</button>
</div>
<div id="upabove" class="visualstate padded shownupabove" style="display: none;">This is the top section.</div>
<div id="inthecenter" class="visualstate padded showninthecenter" style="display: none;">This is the actual page content.</div>
<div id="downbelow" class="visualstate padded showndownbelow" style="display: none;">This is the bottom section.</div>
<div id="linkthatshowspopup" class="visualstate padded" style="display: none;"><a href="javascript:showAlertPopup();">Click me to see the popup!</a></div>
</body>
</html>
<script src="http://webdev.rosedu.org/js/zepto.min.js"></script>
<script src="app.js"></script>
```
The contents of `app.js`:

```
function firstHideAllVisualStatesThenShowTopSection()
{
  $(".visualstate").hide();
  $("#upabove").show();
}
function firstHideAllVisualStatesThenShowPageContent()
{
  $(".visualstate").hide();
  $("#inthecenter").show();
}
function firstHideAllVisualStatesThenShowBottomSection()
{
  $(".visualstate").hide();
  $("#downbelow").show();
}
function firstHideAllVisualStatesThenShowLinkToPopup()
{
  $(".visualstate").hide();
  $("#linkthatshowspopup").show();
}
function showAllVisualStates()
{
  $(".visualstate").show();
}
function showAlertPopup()
{
  alert("JavaScript executed successfully");
}
```

Exercise: replace all 5 instances of `show()` with a nice, smooth "fade-in" visual effect.  
There is an example of how to do this that you can discover if you browse through the source code at https://github.com/roseduwebdev/webdev.rosedu.org/blob/gh-pages/js/main.js

################################################################

We are now going to take another approach to handling user gestures.  
At the moment we are using different approaches for hyperlinks vs. buttons.  
For hyperlinks we are using: `a href="javascript:someFunction();"`  
For buttons we are using: `<button onclick="javascript:someFunction();">`  
This approach has the drawback of unnecesarily cluttering the markup with information about behavior.  
The solution is simple; first let's remove the onclick attributes from all buttons and give an ID to each hyperlink and button, like this:

```
<!DOCTYPE html>
<html>
<head>
<title>My Awesome Web Page</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<div>
<button id="buttonthatdisplaystheupabovediv">Show the top section</button>
<button id="buttonthatdisplaysthecentraldiv">Show the actual page content</button>
<button id="buttonthatdisplaysthedownbelowdiv">Show the bottom section</button>
<button id="buttonthatdisplaysthelinktopopupdiv">Show link to popup</button>
<button id="buttonthatdisplayseverything">Show everything</button>
</div>
<div id="upabove" class="visualstate padded shownupabove" style="display: none;">This is the top section.</div>
<div id="inthecenter" class="visualstate padded showninthecenter" style="display: none;">This is the actual page content.</div>
<div id="downbelow" class="visualstate padded showndownbelow" style="display: none;">This is the bottom section.</div>
<div id="linkthatshowspopup" class="visualstate padded" style="display: none;"><a id="actualhyperlink" href="#">Click me to see the popup!</a></div>
</body>
</html>
<script src="http://webdev.rosedu.org/js/zepto.min.js"></script>
<script src="app.js"></script>
```

You'll notice that we retained the `href` attribute of the `<a>` tag; this is necessary to maintain correct HTML syntax.  
However, we set the value of `href` to `"#"` - this is common practice in web development on the frontend.

################################################################

The second step is to write JavaScript code to attach event listeners to each hyperlink and button.  
The resulting `app.js` will look like this:

```
function firstHideAllVisualStatesThenShowTopSection()
{
  $(".visualstate").hide();
  $("#upabove").show();
}
function firstHideAllVisualStatesThenShowPageContent()
{
  $(".visualstate").hide();
  $("#inthecenter").show();
}
function firstHideAllVisualStatesThenShowBottomSection()
{
  $(".visualstate").hide();
  $("#downbelow").show();
}
function firstHideAllVisualStatesThenShowLinkToPopup()
{
  $(".visualstate").hide();
  $("#linkthatshowspopup").show();
}
function showAllVisualStates()
{
  $(".visualstate").show();
}
function showAlertPopup()
{
  alert("JavaScript executed successfully");
}
$("#buttonthatdisplaystheupabovediv").click( firstHideAllVisualStatesThenShowTopSection );
$("#buttonthatdisplaysthecentraldiv").click( firstHideAllVisualStatesThenShowPageContent );
$("#buttonthatdisplaysthedownbelowdiv").click( firstHideAllVisualStatesThenShowBottomSection );
$("#buttonthatdisplaysthelinktopopupdiv").click( firstHideAllVisualStatesThenShowLinkToPopup );
$("#buttonthatdisplayseverything").click( showAllVisualStates );
$("#actualhyperlink").click( function(e) { e.preventDefault(); showAlertPopup(); } );
```

################################################################

We are now going to focus on CSS styles using the popular Bootstrap framework.  
Before we do, make sure you put your name on the list of students who have completed this exercise.  
Here is the doodle: http://doodle.com/pis9dx26wm2wip82

Finally, add to your HTML file a reference to the Bootstrap framework.  
Your file will now look like this:

```
<!DOCTYPE html>
<html>
<head>
<title>My Awesome Web Page</title>
<link rel="stylesheet" href="http://getbootstrap.com/2.3.2/assets/css/bootstrap.css">
<link rel="stylesheet" href="style.css">
</head>
<body>
<div>
<button id="buttonthatdisplaystheupabovediv">Show the top section</button>
<button id="buttonthatdisplaysthecentraldiv">Show the actual page content</button>
<button id="buttonthatdisplaysthedownbelowdiv">Show the bottom section</button>
<button id="buttonthatdisplaysthelinktopopupdiv">Show link to popup</button>
<button id="buttonthatdisplayseverything">Show everything</button>
</div>
<div id="upabove" class="visualstate padded shownupabove" style="display: none;">This is the top section.</div>
<div id="inthecenter" class="visualstate padded showninthecenter" style="display: none;">This is the actual page content.</div>
<div id="downbelow" class="visualstate padded showndownbelow" style="display: none;">This is the bottom section.</div>
<div id="linkthatshowspopup" class="visualstate padded" style="display: none;"><a id="actualhyperlink" href="#">Click me to see the popup!</a></div>
</body>
</html>
<script src="http://webdev.rosedu.org/js/zepto.min.js"></script>
<script src="app.js"></script>
```

Exercise: Using the documentation available at http://getbootstrap.com/css/#buttons style the buttons in your HTML file according to your own taste.

################################################################

