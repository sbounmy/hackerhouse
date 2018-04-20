import React, { Component } from 'react';
import { connect } from 'react-redux';
import Intercom, { IntercomAPI } from 'react-intercom';
import { hotjar } from 'react-hotjar';

class Widgets extends Component {
  render() {
    // https://www.hotjar.com/
    if (process.env.NODE_ENV =='production') {
      hotjar.initialize(process.env.REACT_APP_HOTJAR_ID, 6);
    }

    if (!this.props.user) {
      return ""
    }
    const user = {
      user_id: this.props.user.id,
      email: this.props.user.email,
      name: `${this.props.user.firstname} ${this.props.user.lastname}`
    };

    return (
      <div>
        <Intercom appID={process.env.REACT_APP_INTERCOM_APP_ID} { ...user } />
      </div>
    );
  }
}

function mapStateToProps({session: { user }}) {
  return { user }
}

export default connect(mapStateToProps)(Widgets);