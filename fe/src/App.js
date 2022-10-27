import React from "react";
import { Container, Button } from "react-bootstrap";
import { FaTwitter } from "react-icons/fa";
import team from "./img/team.compressed.jpeg";
import "./App.css";

function App() {
  return (
    <div className="App">
      <Container>
        <div>
          <p className="contact_me">
            Habla conmigo!{" "}
            <a
              href="https://twitter.com/diekmrcoin"
              target="_blank"
              rel="noreferrer"
            >
              <Button>
                <FaTwitter /> @diekmrcoin
              </Button>
            </a>
          </p>
        </div>
        <br />
        <div>
          <img
            className="appTeamImage"
            src={team}
            alt="Pokemon twitch cup team cartoon"
          />
        </div>
      </Container>
    </div>
  );
}

export default App;
