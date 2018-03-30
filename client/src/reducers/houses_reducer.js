// State argument is not application state, only the state
// this reducer is responsible for
// Never manipulate state. always return a new object/array
import { HOUSE_FETCHED,
         HOUSE_MESSAGES_FETCHED } from '../actions/types';

export default function(state = {}, action) {
  switch(action.type) {
    case HOUSE_FETCHED:
      return { ...state, [action.payload.slug_id]: action.payload };
    case HOUSE_MESSAGES_FETCHED:
      return { ...state, messages: action.payload };
  }
  return state;
}