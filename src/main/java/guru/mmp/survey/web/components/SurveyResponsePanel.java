/*
 * Copyright 2016 Marcus Portmann
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package guru.mmp.survey.web.components;

//~--- non-JDK imports --------------------------------------------------------

import guru.mmp.application.web.template.components.InputPanel;
import guru.mmp.survey.model.SurveyResponse;
import org.apache.wicket.model.IModel;

/**
 * The <code>SurveyResponsePanel</code> class.
 *
 * @author Marcus Portmann
 */
public class SurveyResponsePanel extends InputPanel
{
  private static final long serialVersionUID = 1000000;

  /**
   * Constructs a new <code>SurveyResponsePanel</code>.
   *
   * @param id                  the non-null id of this component
   * @param surveyResponseModel the model for the survey response
   */
  public SurveyResponsePanel(String id, IModel<SurveyResponse> surveyResponseModel)
  {
    super(id);
  }
}
