import React from "react";
import { Container, Button } from "react-bootstrap";
import Row from "react-bootstrap/Row";
import Col from "react-bootstrap/Col";
import { FaTwitter, FaGithub } from "react-icons/fa";
import team from "./img/team.compressed.jpeg";
import "./App.css";

function App() {
  return (
    <div className="App">
      <Container>
        <Row>
          <Col>
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
          </Col>
        </Row>
        <Row>
          <Col>
            <p className="colaborate">
              Éste proyecto es libre y de código abierto, siéntete libre de
              proponer, revisar, programar o comentar.{" "}
              <a
                href="https://github.com/diekmrcoin/pokemon-twitch-cup"
                target="_blank"
                rel="noreferrer"
              >
                <Button variant="secondary">
                  <FaGithub /> PokeTwitchCup
                </Button>
              </a>
            </p>
          </Col>
        </Row>
        <hr />
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
