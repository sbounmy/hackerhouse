// State argument is not application state, only the state
// this reducer is responsible for
// Never manipulate state. always return a new object/array
import { BALANCE_FETCHED } from '../actions/types';

export default function(state = {}, action) {
  switch(action.type) {
    case BALANCE_FETCHED:
      return { ...state, amount: action.payload };
  }
  return state;
}