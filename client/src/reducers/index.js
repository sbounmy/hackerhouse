import { combineReducers } from 'redux';
import sessionsReducer from './sessions_reducer';
import { reducer as formReducer } from 'redux-form';

const rootReducer = combineReducers({
  session: sessionsReducer,
  form: formReducer
});

export default rootReducer;
