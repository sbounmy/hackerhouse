// State argument is not application state, only the state
// this reducer is responsible for
// Never manipulate state. always return a new object/array
import { USER_CREATED_FAILURE
       } from '../actions/types';

export default function(state = {}, action) {
  switch(action.type) {
    case USER_CREATED_FAILURE:
      return { ...state, error: action.payload };
  }
  return state;
}