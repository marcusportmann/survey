/*
 * Copyright 2016 Marcus Portmann
 * All rights reserved.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package digital.survey.web.data;

//~--- non-JDK imports --------------------------------------------------------

import digital.survey.model.ISurveyService;
import digital.survey.model.SurveyDefinition;
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.data.InjectableDataProvider;
import guru.mmp.common.util.StringUtil;
import org.apache.wicket.model.IModel;

import javax.inject.Inject;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>FilteredLatestSurveyDefinitionDataProvider</code> class provides an
 * <code>IDataProvider</code> implementation that retrieves <code>SurveyDefinition</code> instances
 * from the database.
 *
 * This data provider retrieves the latest versions of the survey definition.
 *
 * @author Marcus Portmann
 */
public class FilteredLatestSurveyDefinitionDataProvider
    extends InjectableDataProvider<SurveyDefinition>
{
  private static final long serialVersionUID = 1000000;

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the organisation the survey
   * definitions are associated with.
   */
  private UUID organisationId;

  /**
   * The filter used to limit the matching survey definitions.
   */
  private String filter;

  /**
   * Constructs a new <code>FilteredLatestSurveyDefinitionDataProvider</code>.
   * <p/>
   * Hidden default constructor to support CDI.
   */
  @SuppressWarnings("unused")
  protected FilteredLatestSurveyDefinitionDataProvider() {}

  /**
   * Constructs a new <code>FilteredLatestSurveyDefinitionDataProvider</code>.
   *
   * @param organisationId the Universally Unique Identifier (UUID) used to uniquely identify the
   *                       organisation the survey definitions are associated with
   */
  public FilteredLatestSurveyDefinitionDataProvider(UUID organisationId)
  {
    this.organisationId = organisationId;
  }

  /**
   * @see org.apache.wicket.model.IDetachable#detach()
   */
  public void detach() {}

  /**
   * Returns the filter used to limit the matching survey definitions.
   *
   * @return the filter used to limit the matching survey definitions
   */
  public String getFilter()
  {
    return filter;
  }

  /**
   * Retrieves the matching survey definitions from the database starting with
   * index <code>first</code> and ending with <code>first+count</code>.
   *
   * @param first the index of the first entry to return
   * @param count the number of the entries to return
   *
   * @return the survey definitions retrieved from the database starting with
   * index <code>first</code> and ending with <code>first+count</code>
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#iterator(long, long)
   */
  public Iterator<SurveyDefinition> iterator(long first, long count)
  {
    try
    {
      List<SurveyDefinition> allSurveyDefinitions = StringUtil.isNullOrEmpty(filter)
          ? surveyService.getLatestSurveyDefinitionsForOrganisation(organisationId)
          : surveyService.getFilteredLatestSurveyDefinitionsForOrganisation(organisationId, filter);

      return allSurveyDefinitions.subList((int) first, (int) Math.min(first + count,
          allSurveyDefinitions.size())).iterator();
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(String.format(
          "Failed to load the filtered latest survey definitions"
          + " for the organisation (%s) from index (%d) to (%d)", organisationId, first, first
          + count - 1), e);
    }
  }

  /**
   * Wraps the retrieved <code>SurveyDefinition</code> POJO with a Wicket model.
   *
   * @param surveyDefinition the <code>SurveyDefinition</code> instance to wrap
   *
   * @return the Wicket model wrapping the <code>SurveyDefinition</code> instance
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#model(java.lang.Object)
   */
  public IModel<SurveyDefinition> model(SurveyDefinition surveyDefinition)
  {
    return new DetachableLatestSurveyDefinitionModel(surveyDefinition);
  }

  /**
   * Set the filter used to limit the matching survey definitions.
   *
   * @param filter the filter used to limit the matching survey definitions
   */
  public void setFilter(String filter)
  {
    this.filter = filter;
  }

  /**
   * Returns the total number of survey definitions.
   *
   * @return the total number of survey definitions
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#size()
   */
  public long size()
  {
    try
    {
      return StringUtil.isNullOrEmpty(filter)
          ? surveyService.getNumberOfLatestSurveyDefinitionsForOrganisation(organisationId)
          : surveyService.getNumberOfFilteredLatestSurveyDefinitionsForOrganisation(organisationId,
              filter);
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(String.format("Failed to retrieve the number of filtered"
          + " latest survey definitions for the organisation (%s)", organisationId), e);
    }
  }
}
