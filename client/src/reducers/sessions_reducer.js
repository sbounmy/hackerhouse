// State argument is not application state, only the state
// this reducer is responsible for
// Never manipulate state. always return a new object/array
import { SESSION_CREATED, SESSION_FAILED, SESSION_DESTROYED,
         SESSION_FROM_TOKEN, SESSION_FROM_TOKEN_SUCCESS, SESSION_FROM_TOKEN_FAILURE } from '../actions/types';

export default function(state = {}, action) {
  switch(action.type) {
    case SESSION_CREATED:
      return { ...state, user: action.payload };
    case SESSION_DESTROYED:
      return { ...state, user: null };
    case SESSION_FAILED:
      return { ...state, user: null, error: action.payload };
    case SESSION_FROM_TOKEN:// loading currentUser("me") from jwttoken in local/session storage storage,
      return { ...state, user: null, error:null, loading: true};
    case SESSION_FROM_TOKEN_SUCCESS://return user, status = authenticated and make loading = false
      return { ...state, user: action.payload, error:null, loading: false}; //<-- authenticated
    case SESSION_FROM_TOKEN_FAILURE:// return error and make loading = false
       let error = action.payload.data || {message: action.payload.message};//2nd one is network or server down errors
       return { ...state, user: null,  error:error, loading: false};
  }
  return state;
}