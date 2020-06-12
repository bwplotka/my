# gitpitch based slide decks

See https://gitpitch.com/docs

Shared on: `https://gitpitch.com/bwplotka/my/<branch>?p=<slides-dir>` or locally via `make gitpitch-desktop`

### Quick Tricks

* Normal slide delimiter is `---`, but you can also mix it with  `+++` slide delimiter, which will allow vertical slides (down). 

* Style utilities:
    * The set of available `span-{width}` styles can be used to constrain the horizontal-space used by content (WIDTH CONTROL!)
on your slides. Note, by constraining the horizontal width of specific slide content, the vertical height of that same content is adjusted automatically.
        * Mostly useful for `snap` layouts:
   
         ```markdown
         @snap[north-east span-60]
         @box[bg-purple text-white](Step 1.#Lorem ipsum dolor sit amet, consectetur adipiscing elit.)
         @snapend
         
         @snap[east span-60]
         @box[bg-orange text-white](Step 2.#Sed do eiusmod tempor incididunt ut labore ut enim ad.)
         @snapend
         
         @snap[south-east span-60]
         @box[bg-pink text-white](Step 3.#Cupidatat non proident sunt in culpa officia veniam quis.)
         @snapend
         ```
     
    * Same with colors: 

    ```markdown
    .text-black  { color: #000000 !important; }
    .text-blue   { color: #4487F2 !important; }
    .text-gray   { color: #777777 !important; }
    .text-green  { color: #8EA33B !important; }
    .text-orange { color: #F26225 !important; }
    .text-gold   { color: #E58537 !important; }
    .text-pink   { color: #E71E60 !important; }
    .text-purple { color: #643B85 !important; }
    .text-yellow { color: #F5DB2E !important; }
    .text-white  { color: #FFFFFF !important; }
    ```

    * The set of available `text-{size}` styles can be used to change the font size of plain text rendered on your slides. Sizes represent CSS em values.
    
    * Same with weight:
    
    ```markdown
    .text-bold       { font-weight: bold !important; }
    .text-italic     { font-style: italic !important; }
    .text-italics    { font-style: italic !important; }
    .text-uppercase  { text-transform: uppercase !important; }
    .text-lowercase  { text-transform: lowercase !important; }
    .text-capitalize { text-transform: capitalize !important; }
    .text-smallcaps  { font-variant: small-caps !important; }
    ```
  
    * Alignment: 
    
    ```
     .text-center { text-align: center; }
     .text-left   { text-align: left; }
     .text-right  { text-align: right; }
    ```
  
    * Background color:
    
    ```
     .bg-black  { background: #000000 !important; }
     .bg-blue   { background: #4487F2 !important; }
     .bg-gray   { background: #777777 !important; }
     .bg-green  { background: #8EA33B !important; }
     .bg-orange { background: #F26225 !important; }
     .bg-gold   { background: #E58537 !important; }
     .bg-pink   { background: #E71E60 !important; }
     .bg-purple { background: #643B85 !important; }
     .bg-yellow { background: #F5DB2E !important; }
     .bg-white  { background: #FFFFFF !important; }
  ```
  
   * Bullets:
   
   ```
  .list-circle-bullets    { list-style-type: circle !important; }
  .list-square-bullets    { list-style-type: square !important; }
  .list-alpha-bullets     { list-style-type: upper-alpha !important; }
  .list-roman-bullets     { list-style-type: lower-roman !important; }
  .list-spaced-bullets li { margin-bottom: 1em; }
  .list-no-bullets        { list-style-type: none !important; }
  ```
  
* Nice snap styling: `@quote[...]`, `@gitlink[TEXT](path/to/repo/file.ext)` `@ul[list-spaced-bullets list-fade-fragments]` `@note[Available on Linux, MacOS, and Windows 10.]`
  Other:
  
  ```
  @code - Code Widget
  @gist - GitHub GIST Widget
  @emoji - Emoji Widget
  @tweet - Tweet Widget 
  @table - Table Data Widget
  @cloud - Cloud Diagram Widget
  @uml - UML Diagram Widget
  @uml - LaTeX + AsciiMath Widget
  @audio - Audio Slide Deck Widget
  ```

* `Note:` for notes! Just that. Also `?n=true` to open notes.
* EPIC SPEAKING TRICKS: https://gitpitch.com/docs/speaker-features/demo-gods/

* Survey: https://gitpitch.com/docs/pro-features/surveys/#google-forms-surveys

* Live coding:

```
    ---

    @snap[north-east span-100 text-06 text-gray]
    Live Code Presenting
    @snapend

    ```js
    var io = require('socket.io')(80);
    var cfg = require('./config.json');
    var tw = require('node-tweet-stream')(cfg);

    tw.track('socket.io');
    tw.track('javascript');

    tw.on('tweet', function(tweet){
      io.emit('tweet', tweet);
    });
    ```

    @snap[south span-100]
    @[1](Socket.IO enables real-time, bidirectional, event-based communication.)
    @[2,3](Tweet Stream is node module that connects to the public twitter stream.)
    @[5-10](To process interesting Tweets, simply register a custom handler.)
    @snapend
```

```
 @code[js zoom-12](src/node/sample.js)
 
 @snap[south span-100 text-08]
 @[1, zoom-17](After displaying the full-code, each code presenting step lets you...)
 @[3,4, zoom-16](The ability to focus-and-zoom on specific code snippets directly...)
 @[6-10](Giving you a great way to focus the attention of your audience on what matters most...)
 @snapend
```

```
@code[js code-reveal-slow](src/node/sample.js)

@snap[south span-100 text-08]
@[1, zoom-20](Code revealing *slow-mode* lets you start by hiding the code on your slide.)
@[1-4, zoom-20](And then gradually introduce specific code snippets to your audience.)
@[1-10, zoom-12](Again using optional annotations to focus the attention of your audience.)
@snapend

```

* ASCIICINEMA support: https://gitpitch.com/docs/code-features/terminal-sessions/