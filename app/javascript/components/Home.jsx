import React from "react";
import { useState } from "react";
import '../../assets/stylesheets/application.css'

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

  const s = {
    margin: "auto",
    maxWidth: "600px"
  }

  const img = {
    width: "100%",
    maxWidth: "300px"
  }

  const textarea = {
    backgroundColor: "#201E1F",
    color: "#FF4000",
    fontFamily: 'Abel'
  }

  const a = {
    color: "#FF4000"
  }

  return (
    <div>
      <div style={s}>
        <div>
          <h1>Ask The Ninja</h1>
          <p>
            Ask this book a question. It will respond. Kind of. A bit like a magic book, but more boring, because we think we know how it works. But remember, it is just a book.
            So ask it about the kind of things you would judge it to know -- based on its cover.
          </p>
          <img style={img} src="/cybercover.png"></img>

          <div>
            <p>{answer}</p>
          </div>

          <div>
            <textarea 
              rows = "5" 
              cols = "35" 
              value={text}
              onChange={handleChange}
              style={textarea}
            ></textarea>
          </div>

          <div>
          <button onClick={submit}>Ask</button>
          </div>

        </div>
      </div>
    </div>
  );
}
