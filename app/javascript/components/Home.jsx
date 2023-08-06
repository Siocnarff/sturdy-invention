import React from "react";
import { useState } from "react";

export default function Book() {
  const [text, setText] = useState("What can Ninjas teach us about Cyber Security?");
  const [answer, setAnswer] = useState(null);

  function submit(event) {
    setAnswer("Thinking...");
    fetch("/api/v1/document/ask?" + new URLSearchParams({query: text}))
      .then((response) => {
        if (!response.ok) {
          setAnswer("This book was not able to answer your question. Most likely because too many people are asking it questions now.");
        }
        return response.json();
      })
      .then((data) => {
        setAnswer(data.answer);
      });
  }

  function handleChange(event) {
    setText(event.target.value);
  }

  return (
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
            <textarea 
              rows = "5" 
              cols = "60" 
              value={text}
              onChange={handleChange}
            ></textarea>
          </div>

          <div>
          <button onClick={submit}>Ask</button>
          </div>
          <hr/>

          <div>
            <p>{answer}</p>
          </div>
          
          <img src="/cybercover.png"></img>
        </div>
      </div>
    </div>
  );
}
