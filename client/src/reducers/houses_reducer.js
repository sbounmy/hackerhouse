// State argument is not application state, only the state
// this reducer is responsible for
// Never manipulate state. always return a new object/array
import { HOUSE_FETCHED, HOUSES_FETCHED
       } from '../actions/types';
import _ from 'lodash';

export default function(state = {}, action) {
  switch(action.type) {
    case HOUSE_FETCHED:
      return { ...state, [action.payload.slug_id]: action.payload };
    case HOUSES_FETCHED:
      return _.mapKeys(action.payload, 'id')
  }
  return state;
}