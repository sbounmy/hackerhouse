import React, { Component } from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';

export default function (ComposedComponent) {
  class NoSession extends Component {
    componentWillMount() {
      if (this.props.authenticated) {
        this.props.history.push('/dashboard');
      }
    }

    componentWillUpdate(nextProps) {
      if (nextProps.authenticated) {
        this.props.history.push('/dashboard');
      }
    }

    PropTypes = {
      router: PropTypes.object,
    }

    render() {
      return <ComposedComponent {...this.props} />;
    }
  }

  function mapStateToProps({session: { authenticated }}) {
    return { authenticated };
  }

  return connect(mapStateToProps)(NoSession);
}