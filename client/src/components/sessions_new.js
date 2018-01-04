import React, { Component } from 'react';
import { connect } from 'react-redux';
import { createSession } from '../actions';
import { Link } from 'react-router-dom';
import { Field, reduxForm } from 'redux-form';

class SessionsNew extends Component {
  onSubmit(values) {
    this.props.createSession(values, this.props.history);
  }

  renderField(field) {
    const { meta: { touched, error }, type } = field;
    const className = `form-group ${touched && error ? 'has-danger' : ''}`

    return (
      <div className={className}>
        <label>{field.label}</label>
        <input
        className='form-control'
          type={type}
          {...field.input}
        />
        {touched ? error : ''}
      </div>
    );
  }

  render() {
    const { handleSubmit } = this.props;
    return (
      <form  onSubmit={handleSubmit(this.onSubmit.bind(this))}>
        <Field
          label="Email"
          name="email"
          type="text"
          component={this.renderField}
        />
        <Field
          label="Password"
          name="password"
          type="password"
          component={this.renderField}
        />
        <button type="submit" className="btn btn-primary">Submit</button>
        <Link className="btn btn-danger" to="/">
          Cancel
        </Link>
      </form>
    );
  }
}

function validate(values) {
  // console.log(values) -> { title: 'asdf', categories: 'asd', content: 'isanda'}
  const errors = {};

  // Validate the inputs from 'values'
  if (!values.title || values.title.length < 3) {
    errors.title = "Title must be at least 3 characters";
  }

  // if errors is empty, the form is fine to submit
  // if errors has any properties. redux form assumes form is invalid
  return errors;
}

function mapStateToProps(state) {
  return { errorMessage: state.error };
}

export default reduxForm({
  validate,
  form: 'SessionsNewForm'
})(
  connect(mapStateToProps, { createSession })(SessionsNew)
);