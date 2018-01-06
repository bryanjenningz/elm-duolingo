import './main.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';
import blockQuestions from './mockBlockQuestions.json';
const [question, ...nextQuestions] = blockQuestions;
Main.embed(document.getElementById('root'), { question, nextQuestions });

registerServiceWorker();
