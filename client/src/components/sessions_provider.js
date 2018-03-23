import React, { Component } from 'react';
import { connect } from 'react-redux';
import { createLinkedInSession } from '../actions';
import qs from 'query-string';
import { LINKEDIN_REDIRECT_URI } from './sessions_new';

class SessionsProvider extends Component {
  async componentDidMount() {
    const { history } = this.props;

    if (this.props.user) {
      history.push('/dashboard');
    }
    else {
      const { code } = qs.parse(this.props.location.search);
      try {
        const session = await this.props.createLinkedInSession({code, redirect_uri: LINKEDIN_REDIRECT_URI})
        history.push('/dashboard');
        // do something with response
      } catch(error) {
        alert('error', error);
      }
    }
  }

  render() {
    const { code } = qs.parse(this.props.location.search)
    return (
      <div className='text-center'>
        <h3>Loading....</h3>
        <p>Remember to get up and stretch once in a while. 💪</p>
      </div>
    );
  }
}

function mapStateToProps({ session: { user } }) {
  return { user };
}

export default connect(mapStateToProps, { createLinkedInSession })(SessionsProvider);