import './main.css';
import { Elm } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

const app = Elm.Main.init({
  node: document.getElementById('root'),
  flags: 5 
});

app.ports.output.subscribe(console.log);

setTimeout(
  () => {
    console.log('here');
    app.ports.incoming.send([{ score: 1, total: 2}])
  }
      , 1000)

registerServiceWorker();
