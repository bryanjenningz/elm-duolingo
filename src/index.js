import './main.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';
import blockQuestions from './mockBlockQuestions.json';

Main.embed(document.getElementById('root'), { blockQuestions });

registerServiceWorker();
