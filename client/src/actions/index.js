import axios from 'axios';
import cookie from 'react-cookie';
import { SESSION_CREATED, SESSION_FAILED, SESSION_DESTROYED, USER_CREATED } from './types';

const ROOT_URL = `${process.env.REACT_APP_API}/v1`;

export function createSession({ email, password, linkedin_access_token }, history) {
  const url = `${ROOT_URL}/sessions`;

  return async (dispatch) => {
    try {
      const res = await axios.post(url, { email, password, linkedin_access_token });

      dispatch({ type: SESSION_CREATED, payload: res.data.user });
      localStorage.setItem('token', res.data.token);
      localStorage.setItem('user',  JSON.stringify(res.data.user));
      history.push('/dashboard');
    } catch(error) {
      dispatch({
        type: SESSION_FAILED,
        payload: 'Invalid email or password'
      });
    }
  };
}

export function destroySession() {
  localStorage.clear();
  return {
    type: SESSION_DESTROYED
  };
}

export function createUser(data) {
  const url = `${process.env.REACT_APP_API}/v2/users`;
  return (dispatch) => {
    return axios.post(url, data).then((res) => {
      dispatch({ type: USER_CREATED, payload: res.data });
    })
  };
}

export function createLinkedInSession({code, redirect_uri}, history) {
  const url = `${ROOT_URL}/tokens/linkedin`;

  return async (dispatch) => {
    // try {
      const res = await axios.get(url, { params: { code, redirect_uri } })
      .then(({data}) => {
        data.linkedin_access_token = data.token
        data.password = "blabla1234"
        dispatch(createUser(data)).then(() => {
          dispatch(createSession({ email: data.email, linkedin_access_token: data.token }, history));
        });
      });

      // localStorage.setItem('token', res.data.token);
      // localStorage.setItem('user',  JSON.stringify(res.data.user));
    // } catch(error) {
    //   dispatch({
    //     type: SESSION_FAILED,
    //     payload: 'Invalid email or password'
    //   });
    // }
  };
}