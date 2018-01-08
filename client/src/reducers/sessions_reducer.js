// State argument is not application state, only the state
// this reducer is responsible for
// Never manipulate state. always return a new object/array
import { SESSION_CREATED, SESSION_FAILED, SESSION_DESTROYED } from '../actions/types';

export default function(state = {}, action) {
  switch(action.type) {
    case SESSION_CREATED:
      return { ...state, authenticated: true, user: action.payload };
    case SESSION_DESTROYED:
      return { ...state, authenticated: false };
    case SESSION_FAILED:
      return { ...state, error: action.payload };
  }
  return state;
}