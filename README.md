# truffle.pageload

A simple page loading extension for javascript applications.

# Introduction

This extension is for applications that on initialization have requests to make in order to completely render the application.

# Usage

Include the library as early as possible in the page, then initialize the library using the following code. This application is very small, and doesn't depend on external libraries so should not adversely effect page load speed. The call list here is just an example, and the array can contain regexes as well. It's up to you what done and progress functions do. This allows you to have full control of your user experience.

```html
	<script type="text/javascript">
		var pageLoader = new (require('truffle.pageload/application'));
		pageLoader.initialize({
			callList: [
				'/api/test',
				'/api/settings',
				'/api/settings/test'
			],
			done: function() { console.log('done'); },
			progress: function(progress) { console.log(progress); }
		});
	</script>
```

# History

## patch
* Supporting open and close progress updates for more interactive results
* Fixing support in browsers without require features

## 1.0.0
* Supporting watching for known ajax requests and binding to configurable element updating
