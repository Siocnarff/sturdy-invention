import React from "react";

export default () => (
  <div>
    <div>
      <div>
        <h1>A Book...</h1>
        <p>
          Ask this book a question and it will answer you. But remember, it is just a book. <br/>
          So ask it about the kind of things you would judge it to know -- based on its cover. :)
        </p>
        <hr/>

        <div>
        <textarea rows = "5" cols = "60"></textarea>
        </div>
        
        <div>
        <button>Submit</button>
        </div>
        <hr/>
        
        <img src="/cybercover.png"></img>
      </div>
    </div>
  </div>
);
